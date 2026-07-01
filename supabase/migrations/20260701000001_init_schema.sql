-- ================================================
-- Fortune Master · 初始化数据库 Schema
-- 2026-07-01 · Week 2 落地
-- 遵循 privacy: 原始经纬度用完即弃, 不永久明文存储
-- ================================================

-- 1. profiles (用户档案)
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  display_name text,
  locale text default 'en' check (locale in ('en', 'zh-CN', 'zh-HK')),
  -- 用户主动保存的出生信息 (跨设备同步)
  birth_date date,
  birth_time time,
  birth_city text,        -- 只存城市名, 不存原始经纬度
  birth_tz text,          -- 时区字符串 e.g. 'Asia/Shanghai'
  gender text check (gender in ('male', 'female', 'other')),
  free_credits int default 5,
  is_premium boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_profiles_locale on profiles(locale);

-- 2. readings (排盘记录) - 隐私优先
-- input_payload 排盘计算完后立即清空原始经纬度,
-- chart_data 永久保留脱敏后的排盘结果.
create table readings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  system text not null,           -- 'bazi' | 'ziwei' | 'iching' | 'tarot' | 'qimen' | 'liuyao' | 'meihua' | 'taiyi' | 'daliuren' | 'xiaoliuren' | 'horoscope' | 'dream'
  input_payload jsonb,            -- 排盘计算后清空原始经纬度
  chart_data jsonb not null,      -- 永久: 排盘结果 (已是脱敏数据)
  tier text default 'free' check (tier in ('free', 'brief', 'detailed', 'pdf')),
  llm_interp text,                -- LLM 解读全文
  llm_model text,
  llm_prompt_tokens int,
  llm_completion_tokens int,
  is_public boolean default false, -- 用户是否分享到社区
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_readings_user on readings(user_id);
create index idx_readings_system on readings(system);
create index idx_readings_created on readings(created_at desc);
-- 公开解读索引 (社区展示用)
create index idx_readings_public on readings(is_public, created_at desc) where is_public = true;

-- 3. posts (社区分享)
create table posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  reading_id uuid references readings(id) on delete set null,
  title text,
  body text not null,
  image_url text,                 -- 分享卡图片 (Storage)
  tags text[],
  is_anonymous boolean default false,
  is_hidden boolean default false, -- 举报后人工隐藏
  report_count int default 0,    -- 举报计数
  created_at timestamptz default now()
);

create index idx_posts_user on posts(user_id);
create index idx_posts_created on posts(created_at desc);
create index idx_posts_hidden on posts(is_hidden) where is_hidden = false;

-- 4. post_reactions (评论/点赞)
create table post_reactions (
  post_id uuid references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  kind text check (kind in ('like', 'comment')),
  body text,                      -- 评论内容 (kind='comment' 时填)
  created_at timestamptz default now(),
  primary key (post_id, user_id, kind)
);

create index idx_reactions_post on post_reactions(post_id);

-- 5. subscriptions (订阅状态 - RevenueCat webhook 同步)
create table subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  plan text check (plan in ('monthly', 'yearly')),
  status text check (status in ('active', 'expired', 'cancelled', 'refunded')),
  current_period_end timestamptz,
  rc_original jsonb,              -- RevenueCat 原始 payload 存档
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index idx_subs_user on subscriptions(user_id);
create index idx_subs_status on subscriptions(user_id, status, current_period_end);

-- 6. credit_logs (配额使用日志)
create table credit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  delta int not null,             -- 正: 增加 (免费/广告/订阅), 负: 消耗
  reason text check (reason in ('free_signup', 'ad_watched', 'premium_credit', 'reading_used', 'manual_adjust')),
  reading_id uuid references readings(id) on delete set null,
  meta jsonb,
  created_at timestamptz default now()
);

create index idx_credits_user on credit_logs(user_id, created_at desc);

-- 7. reports (举报)
create table reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references profiles(id) on delete set null,
  target_type text check (target_type in ('post', 'comment', 'user')),
  target_id uuid not null,
  reason text check (reason in ('spam', 'abuse', 'inappropriate', 'other')),
  body text,
  status text default 'pending' check (status in ('pending', 'reviewed', 'dismissed', 'actioned')),
  reviewed_by uuid references profiles(id),
  created_at timestamptz default now()
);

create index idx_reports_status on reports(status, created_at desc);

-- ================================================
-- Row Level Security (RLS) - Week 2 中期落地
-- ================================================

-- profiles: 用户只能读写自己
alter table profiles enable row level security;
create policy "users can view own profile" on profiles for select using (auth.uid() = id);
create policy "users can update own profile" on profiles for update using (auth.uid() = id);

-- readings: 用户读写自己的
alter table readings enable row level security;
create policy "users can manage own readings" on readings for all using (auth.uid() = user_id);
-- 公开解读任何人都能看 (社区列表)
create policy "anyone can view public readings" on readings for select using (is_public = true);

-- posts: 公开可读, 作者能管理
alter table posts enable row level security;
create policy "anyone can view non-hidden posts" on posts for select using (is_hidden = false);
create policy "users can manage own posts" on posts for all using (auth.uid() = user_id);

-- post_reactions: 公开可读, 用户写自己
alter table post_reactions enable row level security;
create policy "anyone can view reactions" on post_reactions for select using (true);
create policy "users can manage own reactions" on post_reactions for all using (auth.uid() = user_id);

-- subscriptions: 用户只看自己
alter table subscriptions enable row level security;
create policy "users can view own subscriptions" on subscriptions for select using (auth.uid() = user_id);

-- credit_logs: 用户只看自己
alter table credit_logs enable row level security;
create policy "users can view own credit logs" on credit_logs for select using (auth.uid() = user_id);

-- reports: 用户可创建, 管理员审核 (管理员 role 通过自定义 claims 走 service_role)
alter table reports enable row level security;
create policy "users can create reports" on reports for insert with check (auth.uid() = reporter_id);
create policy "users can view own reports" on reports for select using (auth.uid() = reporter_id);

-- ================================================
-- 触发器
-- ================================================

-- updated_at 自动更新
create or replace function update_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_profiles_updated before update on profiles
for each row execute function update_updated_at();

create trigger trg_readings_updated before update on readings
for each row execute function update_updated_at();

create trigger trg_subs_updated before update on subscriptions
for each row execute function update_updated_at();

-- 用户注册自动创建 profile (从 auth.users 取邮箱)
create or replace function handle_new_user() returns trigger as $$
begin
  insert into public.profiles (id, display_name, locale)
  values (new.id, split_part(new.email, '@', 1),
    case
      when new.email ~ '[\x{4e00}-\x{9fa5}]' then 'zh-CN'
      else 'en'
    end
  );
  -- 赠送初始免费次数
  insert into public.credit_logs (user_id, delta, reason) values (new.id, 5, 'free_signup');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ================================================
-- Seed Data (周公解梦原文, 公版)
-- ================================================
-- 注意: 真正部署前从中国哲学书电子化计划或维基文库导入《周公解梦》原文
-- 这里只放 3 条示例, 后续 migration 替换

create table dream_dict (
  keyword text primary key,
  interpretation_zh text not null,
  interpretation_en text not null,
  category text
);

insert into dream_dict (keyword, interpretation_zh, interpretation_en, category) values
  ('龙', '主官显位高, 大吉之兆', 'Dragon — auspicious sign of rising status and authority', 'auspicious'),
  ('蛇', '主财运或神秘之事', 'Snake — sign of wealth or mysterious events', 'neutral'),
  ('水', '主财源广进', 'Water — abundant financial fortune', 'auspicious');

-- ================================================
-- 注释: Week 2 验收检查
-- ================================================
-- psql 检查清单:
-- 1. select * from profiles limit 1;     -- 应有注册用户
-- 2. select count(*) from dream_dict;    -- 应 = 3
-- 3. select * from readings limit 1;     -- 排盘结果 JSONB 可解析
-- 4. psql \d+ profiles                   -- RLS policy 启用
