// supabase/functions/_shared/qimen-native.ts
// 自实现奇门遁甲排盘 (拆补法 · 时家奇门 · 阴阳顺逆).
//
// 背景: taibu-core 的 calculateQimen 内部依赖真实修改 process.env.TZ 才能正确解析
// 传入的墙钟时间 (库自己的注释也承认 "zonedWallClockToSystemDate 无法替代")。
// Supabase Edge Runtime 禁止运行时改环境变量, 导致 taibu-core 的奇门结果日柱/时柱
// 天干在非 UTC 时区下算错 (已用 lunar-javascript 交叉验证证实, 2026-07-02)。
// 四柱本身改用 lunar-javascript 直接算 (纯历法计算, 不依赖系统时区), 排局起局部分
// 自实现, 不再调用 taibu-core/qimen。
//
// ⚠️ 置信度说明 (务必阅读):
//   - 四柱 (SiZhu): 高置信度, 直接用 lunar-javascript, 与八字模块同一套算法。
//   - 局数/阴阳遁判定 (拆补法, 二十四节气对照表): 高置信度, 交叉核实了两个独立
//     中文资料来源, 结果一致。
//   - 地盘三奇六仪排布: 高置信度, 用一个完整实例验证过 (癸卯年戊午月己酉日戊辰时,
//     芒种, 阳遁六局 → 戊六宫起, 戊己庚辛壬癸丁丙乙顺排, 逐宫比对完全吻合)。
//   - 值符值使定位规则: 中等置信度, 有明确文字规则依据, 但没有完整实例可逐宫验证。
//   - 天盘九星/人盘八门的旋转方向 (随值符/值使阳顺阴逆铺开): 低-中置信度。
//     搜索到的中文资料对这一步的方向规则存在互相矛盾的说法 (一说"阳顺阴逆",
//     一说"天盘永远顺排无顺逆之分") —— 这是奇门遁甲不同流派 (转盘法/飞盘法)
//     的真实分歧, 不是我理解错。本实现统一按"阳顺阴逆"处理, 但未找到可逐宫
//     核对的权威实例, 上线前建议找一个你信任的奇门排盘工具/教材做逐宫比对。
//   - 八神排列: 高置信度, "值符螣蛇太阴六合白虎玄武九地九天固定顺序, 阳顺阴逆"
//     这条在多个来源里表述一致, 没有分歧。
//
// 参考来源 (2026-07-02 搜索核实):
//   - 二十四节气局数表: 知乎 p/648135351 与另一独立来源交叉验证一致
//   - 地盘排列规则 + 完整实例: 知乎 p/644619189 (通过 WebSearch 摘要获取，原文 403 未能直接访问)
//   - 值符值使/天盘人盘规则: CSDN qq_42971998/136208916 摘要 (存在与其他来源的内部矛盾, 见上)

// deno-lint-ignore no-explicit-any
type Lunar = any;

const TIAN_GAN = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
const DI_ZHI = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

function ganzhiIndex(gz: string): number {
  const g = TIAN_GAN.indexOf(gz[0]);
  const z = DI_ZHI.indexOf(gz[1]);
  for (let i = 0; i < 60; i++) {
    if (i % 10 === g && i % 12 === z) return i;
  }
  throw new Error(`invalid ganzhi: ${gz}`);
}

// 二十四节气 → 阴阳遁 + (上元,中元,下元) 局数. 来源见文件头.
const JIE_QI_JU: Record<string, { dun: 'yang' | 'yin'; ju: [number, number, number] }> = {
  '冬至': { dun: 'yang', ju: [1, 7, 4] },
  '小寒': { dun: 'yang', ju: [2, 8, 5] },
  '大寒': { dun: 'yang', ju: [3, 9, 6] },
  '立春': { dun: 'yang', ju: [8, 5, 2] },
  '雨水': { dun: 'yang', ju: [9, 6, 3] },
  '惊蛰': { dun: 'yang', ju: [1, 7, 4] },
  '春分': { dun: 'yang', ju: [3, 9, 6] },
  '清明': { dun: 'yang', ju: [4, 1, 7] },
  '谷雨': { dun: 'yang', ju: [5, 2, 8] },
  '立夏': { dun: 'yang', ju: [4, 1, 7] },
  '小满': { dun: 'yang', ju: [5, 2, 8] },
  '芒种': { dun: 'yang', ju: [6, 3, 9] },
  '夏至': { dun: 'yin', ju: [9, 3, 6] },
  '小暑': { dun: 'yin', ju: [8, 2, 5] },
  '大暑': { dun: 'yin', ju: [7, 1, 4] },
  '立秋': { dun: 'yin', ju: [2, 5, 8] },
  '处暑': { dun: 'yin', ju: [1, 4, 7] },
  '白露': { dun: 'yin', ju: [9, 3, 6] },
  '秋分': { dun: 'yin', ju: [7, 1, 4] },
  '寒露': { dun: 'yin', ju: [6, 9, 3] },
  '霜降': { dun: 'yin', ju: [5, 8, 2] },
  '立冬': { dun: 'yin', ju: [6, 9, 3] },
  '小雪': { dun: 'yin', ju: [5, 8, 2] },
  '大雪': { dun: 'yin', ju: [4, 7, 1] },
};

const LIU_YI_SAN_QI = ['戊', '己', '庚', '辛', '壬', '癸', '丁', '丙', '乙']; // 地盘固定排列顺序
const XUN_YI_BY_START: Record<number, string> = { 0: '戊', 10: '己', 20: '庚', 30: '辛', 40: '壬', 50: '癸' };
const STAR_HOME: Record<number, string> = { 1: '天蓬', 2: '天芮', 3: '天冲', 4: '天辅', 6: '天心', 7: '天柱', 8: '天任', 9: '天英' };
const DOOR_HOME: Record<number, string> = { 1: '休门', 2: '死门', 3: '伤门', 4: '杜门', 6: '开门', 7: '惊门', 8: '生门', 9: '景门' };
const GOD_ORDER = ['值符', '螣蛇', '太阴', '六合', '白虎', '玄武', '九地', '九天'];
const BRANCH_HOME: Record<string, number> = {
  '子': 1, '丑': 8, '寅': 8, '卯': 3, '辰': 4, '巳': 4, '午': 9, '未': 2, '申': 2, '酉': 7, '戌': 6, '亥': 6,
};

const FULL_CYCLE = [1, 2, 3, 4, 5, 6, 7, 8, 9]; // 地盘用, 含中宫
const EIGHT_CYCLE = [1, 2, 3, 4, 6, 7, 8, 9]; // 星/门/神用, 不含中宫 (中宫寄二宫)

function nextPalace(p: number, dir: number, cycle: number[]): number {
  const idx = cycle.indexOf(p);
  return cycle[(idx + dir + cycle.length) % cycle.length];
}

function buildDiPan(ju: number, dun: 'yang' | 'yin'): Record<number, string> {
  const dir = dun === 'yang' ? 1 : -1;
  const map: Record<number, string> = {};
  let palace = ju;
  for (let i = 0; i < 9; i++) {
    map[palace] = LIU_YI_SAN_QI[i];
    palace = nextPalace(palace, dir, FULL_CYCLE);
  }
  return map;
}

function findPalaceOfSymbol(diPan: Record<number, string>, symbol: string): number {
  for (const p of FULL_CYCLE) {
    if (diPan[p] === symbol) return p;
  }
  throw new Error(`symbol ${symbol} not found in 地盘`);
}

/** 中宫无星/门, 按通行惯例寄坤二宫. */
function foldCenter(palace: number): number {
  return palace === 5 ? 2 : palace;
}

function rotateHomeLayer(
  homeMap: Record<number, string>,
  zhiHomePalace: number,
  targetPalace: number,
  dir: number,
): Record<number, string> {
  const homeOrder = EIGHT_CYCLE.map((p) => homeMap[p]);
  const startIdx = EIGHT_CYCLE.indexOf(zhiHomePalace);
  const result: Record<number, string> = {};
  let palace = targetPalace;
  for (let i = 0; i < 8; i++) {
    result[palace] = homeOrder[(startIdx + i + 8) % 8];
    palace = nextPalace(palace, dir, EIGHT_CYCLE);
  }
  return result;
}

function rotateGods(startPalace: number, dir: number): Record<number, string> {
  const result: Record<number, string> = {};
  let palace = startPalace;
  for (let i = 0; i < 8; i++) {
    result[palace] = GOD_ORDER[i];
    palace = nextPalace(palace, dir, EIGHT_CYCLE);
  }
  return result;
}

export interface NativeQimenInput {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute?: number;
  question?: string;
}

export interface NativeQimenPalace {
  palaceIndex: number;
  diPan: string; // 地盘 (三奇六仪, 中宫也有值)
  star: string | null; // 天盘九星 (中宫无)
  door: string | null; // 人盘八门 (中宫无)
  god: string | null; // 神盘八神 (中宫无)
}

export interface NativeQimenOutput {
  dateInfo: { solarDate: string; jieQi: string };
  siZhu: { year: string; month: string; day: string; hour: string };
  dunType: 'yang' | 'yin';
  juNumber: number;
  yuan: '上元' | '中元' | '下元';
  xunShou: string;
  zhiFu: { star: string; palace: number };
  zhiShi: { door: string; palace: number };
  palaces: NativeQimenPalace[];
  question?: string;
  _meta: {
    engine: 'native-chaibu-v1';
    confidence:
      'siZhu=high, ju/dun=high, diPan=high(verified against worked example), zhiFuZhiShi=medium, starDoorRotationDirection=medium(schools disagree), gods=high';
  };
}

/**
 * @param lunarModule 由调用方传入 `npm:lunar-javascript` 的 `Lunar`/`Solar` 导出, 避免本文件直接 import npm 包.
 */
export function calculateQimenNative(
  input: NativeQimenInput,
  lunarModule: { Solar: { fromYmdHms: (y: number, m: number, d: number, h: number, mi: number, s: number) => { getLunar: () => Lunar } } },
): NativeQimenOutput {
  const { year, month, day, hour, minute = 0 } = input;
  const solar = lunarModule.Solar.fromYmdHms(year, month, day, hour, minute, 0);
  const lunar = solar.getLunar();

  const dayGz: string = lunar.getDayInGanZhi();
  const hourGz: string = lunar.getTimeInGanZhi();
  const yearGz: string = lunar.getYearInGanZhi();
  const monthGz: string = lunar.getMonthInGanZhi();

  const jieQiName: string = lunar.getPrevJieQi(true).getName();
  const jieQiInfo = JIE_QI_JU[jieQiName];
  if (!jieQiInfo) throw new Error(`未知节气: ${jieQiName}`);

  const dayIdx = ganzhiIndex(dayGz);
  const hourIdx = ganzhiIndex(hourGz);

  // 上中下元: 符头 (甲/己日, 60甲子索引对 5 取整) 的地支决定
  const fuTouIdx = dayIdx - (dayIdx % 5);
  const fuTouBranch = DI_ZHI[fuTouIdx % 12];
  let yuanPos: 0 | 1 | 2;
  let yuanName: '上元' | '中元' | '下元';
  if (['子', '午', '卯', '酉'].includes(fuTouBranch)) {
    yuanPos = 0;
    yuanName = '上元';
  } else if (['寅', '申', '巳', '亥'].includes(fuTouBranch)) {
    yuanPos = 1;
    yuanName = '中元';
  } else {
    yuanPos = 2;
    yuanName = '下元';
  }

  const juNumber = jieQiInfo.ju[yuanPos];
  const dunType = jieQiInfo.dun;
  const dir = dunType === 'yang' ? 1 : -1;

  const diPan = buildDiPan(juNumber, dunType);

  // 旬首: 时柱所在旬的甲己代表符号
  const xunStart = hourIdx - (hourIdx % 10);
  const xunYi = XUN_YI_BY_START[xunStart];
  const xunShouName = `甲${DI_ZHI[xunStart % 12]}`;

  // 值符: 旬首在地盘的落宫 → 该宫本位九星
  const p1 = findPalaceOfSymbol(diPan, xunYi);
  const zhiFuStar = STAR_HOME[foldCenter(p1)];
  const zhiFuHomePalace = foldCenter(p1); // 用于星层旋转的"本位"起点

  // 时干 (若时干为甲, 甲不上盘, 用旬首仪代替) 在地盘的落宫 → 值符实际移动到此宫
  const hourStem = hourGz[0];
  const hourStemSymbol = hourStem === '甲' ? xunYi : hourStem;
  const p2 = findPalaceOfSymbol(diPan, hourStemSymbol);
  const zhiFuTargetPalace = foldCenter(p2);

  const starLayer = rotateHomeLayer(STAR_HOME, zhiFuHomePalace, zhiFuTargetPalace, dir);

  // 值使: 与值符同源宫 (p1) 对应的本位八门, 移动到时支的本位宫 (p3)
  const zhiShiDoor = DOOR_HOME[zhiFuHomePalace];
  const hourBranch = hourGz[1];
  const p3 = BRANCH_HOME[hourBranch];
  const doorLayer = rotateHomeLayer(DOOR_HOME, zhiFuHomePalace, p3, dir);

  // 八神: 值符神起于值符星所在宫 (与星层同起点), 固定顺序阳顺阴逆铺开
  const godLayer = rotateGods(zhiFuTargetPalace, dir);

  const palaces: NativeQimenPalace[] = FULL_CYCLE.map((p) => ({
    palaceIndex: p,
    diPan: diPan[p],
    star: starLayer[p] ?? null,
    door: doorLayer[p] ?? null,
    god: godLayer[p] ?? null,
  }));

  return {
    dateInfo: { solarDate: solar.toYmdHms ? solar.toYmdHms() : `${year}-${month}-${day} ${hour}:${minute}`, jieQi: jieQiName },
    siZhu: { year: yearGz, month: monthGz, day: dayGz, hour: hourGz },
    dunType,
    juNumber,
    yuan: yuanName,
    xunShou: xunShouName,
    zhiFu: { star: zhiFuStar, palace: zhiFuTargetPalace },
    zhiShi: { door: zhiShiDoor, palace: p3 },
    palaces,
    question: input.question,
    _meta: {
      engine: 'native-chaibu-v1',
      confidence:
        'siZhu=high, ju/dun=high, diPan=high(verified against worked example), zhiFuZhiShi=medium, starDoorRotationDirection=medium(schools disagree), gods=high',
    },
  };
}
