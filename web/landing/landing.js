// web/landing/landing.js
// 主页与子页共享: 星空背景 + 八卦图 + 十二地支环.
// 卡片数据在 DATA 数组, 可被 index.html 与 demo.html 共用 (demo 页用 mini subset).

(function () {
  'use strict';

  /* ---------- star field ---------- */
  const cv = document.getElementById('sky');
  if (cv) {
    const cx = cv.getContext('2d');
    let stars = [];
    function resize() {
      cv.width = window.innerWidth;
      cv.height = window.innerHeight;
      stars = Array.from(
        { length: Math.floor((window.innerWidth * window.innerHeight) / 9000) },
        () => ({
          x: Math.random() * cv.width,
          y: Math.random() * cv.height,
          r: Math.random() * 1.1 + 0.2,
          p: Math.random() * Math.PI * 2,
          s: 0.5 + Math.random() * 1.5,
        })
      );
    }
    window.addEventListener('resize', resize);
    resize();
    (function tick(t) {
      cx.clearRect(0, 0, cv.width, cv.height);
      const time = t / 1000;
      for (const st of stars) {
        const a = 0.25 + 0.55 * Math.abs(Math.sin(st.p + time * st.s * 0.4));
        cx.beginPath();
        cx.arc(st.x, st.y, st.r, 0, 7);
        cx.fillStyle = `rgba(122,90,42,${a})`;
        cx.fill();
      }
      requestAnimationFrame(tick);
    })(0);
  }

  /* ---------- bagua trigrams ---------- */
  const TRI = [
    [1, 1, 1],
    [0, 1, 1],
    [1, 0, 1],
    [0, 0, 1],
    [1, 1, 0],
    [0, 1, 0],
    [1, 0, 0],
    [0, 0, 0],
  ]; // 乾兌離震巽坎艮坤
  const tg = document.getElementById('trigrams');
  if (tg) {
    TRI.forEach((lines, i) => {
      const ang = i * 45 - 90;
      const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
      g.setAttribute('transform', `rotate(${ang} 170 170) translate(170 34)`);
      lines.forEach((solid, j) => {
        const y = j * 8;
        if (solid) {
          g.innerHTML += `<rect x="-16" y="${y}" width="32" height="4" fill="#9a742e" fill-opacity=".8"/>`;
        } else {
          g.innerHTML += `<rect x="-16" y="${y}" width="13" height="4" fill="#9a742e" fill-opacity=".8"/>
                          <rect x="3" y="${y}" width="13" height="4" fill="#9a742e" fill-opacity=".8"/>`;
        }
      });
      tg.appendChild(g);
    });
  }

  /* ---------- zodiac / earthly branch ring ---------- */
  const BR = '子丑寅卯辰巳午未申酉戌亥'.split('');
  const zr = document.getElementById('zodiacring');
  if (zr) {
    BR.forEach((ch, i) => {
      const a = ((i * 30 - 90) * Math.PI) / 180;
      const x = 170 + Math.cos(a) * 136;
      const y = 170 + Math.sin(a) * 136;
      const t = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      t.setAttribute('x', x);
      t.setAttribute('y', y + 4.5);
      t.textContent = ch;
      zr.appendChild(t);
    });
  }

  /* ---------- divination cards (8 arts) ----------
     route  对应 Flutter SPA 的 go_router 路径, 在 /landing/ 页直接用 hash 跳 (#/bazi)
     detail 对应 /landing/arts/{slug}.html 子页
  ----------------------------------------------- */
  const gold = '#9a742e';
  const goldB = '#7d5a1c';
  const CARDS = [
    {
      slug: 'bazi',
      zh: '八字',
      en: 'FOUR PILLARS · BAZI',
      hot: false,
      desc: '以生辰四柱天干地支，推演一生格局起伏。',
      svg: `<g class="glow-on-hover" stroke="${gold}" fill="none" stroke-width="1.2">
        <rect x="14" y="10" width="10" height="54" rx="1"/><rect x="30" y="10" width="10" height="54" rx="1"/>
        <rect x="46" y="10" width="10" height="54" rx="1"/><rect x="62" y="10" width="10" height="54" rx="1" stroke="${goldB}"/>
        <line x1="14" y1="37" x2="72" y2="37" stroke-opacity=".5"/></g>`,
    },
    {
      slug: 'ziwei',
      zh: '紫微斗數',
      en: 'ZI WEI DOU SHU',
      hot: false,
      desc: '十四主星飛佈十二宮，命宮財帛官祿盡覽。',
      svg: `<g class="glow-on-hover" stroke="${gold}" fill="none" stroke-width="1">
        <rect x="10" y="10" width="54" height="54"/>
        <path d="M28 10v54M46 10v54M10 28h54M10 46h54" stroke-opacity=".55"/>
        <circle cx="37" cy="37" r="7" stroke="${goldB}"/><circle cx="37" cy="37" r="1.6" fill="${goldB}" stroke="none"/></g>`,
    },
    {
      slug: 'iching',
      zh: '周易六爻',
      en: 'I CHING',
      hot: false,
      desc: '三枚銅錢起卦，六爻動靜之間窺見事機。',
      svg: `<g class="glow-on-hover" fill="${gold}">
        <rect x="14" y="12" width="46" height="5"/><rect x="14" y="22" width="20" height="5"/><rect x="40" y="22" width="20" height="5"/>
        <rect x="14" y="32" width="46" height="5" fill="${goldB}"/><rect x="14" y="42" width="20" height="5"/><rect x="40" y="42" width="20" height="5"/>
        <rect x="14" y="52" width="46" height="5"/><rect x="14" y="62" width="20" height="5"/><rect x="40" y="62" width="20" height="5"/></g>`,
    },
    {
      slug: 'meihua',
      zh: '梅花易數',
      en: 'PLUM BLOSSOM',
      hot: false,
      desc: '觸機起卦、體用生剋，數起於心而應於物。',
      svg: `<g class="glow-on-hover" stroke="${gold}" fill="none" stroke-width="1.2">
        <circle cx="37" cy="24" r="9"/><circle cx="24" cy="34" r="9"/><circle cx="50" cy="34" r="9"/>
        <circle cx="29" cy="48" r="9"/><circle cx="45" cy="48" r="9"/>
        <circle cx="37" cy="37" r="3" fill="${goldB}" stroke="none"/></g>`,
    },
    {
      slug: 'tarot',
      zh: '塔羅',
      en: 'TAROT',
      hot: true,
      desc: '七十八張韋特塔羅，凱爾特十字與三牌陣。',
      svg: `<g class="glow-on-hover" stroke="${gold}" fill="none" stroke-width="1.2">
        <rect x="12" y="16" width="28" height="44" rx="2" transform="rotate(-9 26 38)"/>
        <rect x="30" y="12" width="30" height="48" rx="2" stroke="${goldB}"/>
        <path d="M45 22l2.6 5.6 6 .6-4.5 4 1.3 5.8-5.4-3-5.4 3 1.3-5.8-4.5-4 6-.6z" fill="${gold}" stroke="none" fill-opacity=".9"/></g>`,
    },
    {
      slug: 'qimen',
      zh: '奇門遁甲',
      en: 'QI MEN DUN JIA',
      hot: false,
      desc: '九宮飛盤、八門九星，古之帝王決策之學。',
      svg: `<g class="glow-on-hover" stroke="${gold}" fill="none" stroke-width="1">
        <rect x="12" y="12" width="50" height="50" transform="rotate(45 37 37)"/>
        <rect x="21" y="21" width="32" height="32" transform="rotate(45 37 37)" stroke-opacity=".6"/>
        <circle cx="37" cy="37" r="4" stroke="${goldB}"/>
        <path d="M37 5v12M37 57v12M5 37h12M57 37h12" stroke-opacity=".7"/></g>`,
    },
    {
      slug: 'astro',
      zh: '西方占星',
      en: 'ASTROLOGY',
      hot: false,
      desc: '本命盤十大行星落宮，行運相位逐年推演。',
      svg: `<g class="glow-on-hover" stroke="${gold}" fill="none" stroke-width="1">
        <circle cx="37" cy="37" r="27"/><circle cx="37" cy="37" r="19" stroke-opacity=".5"/>
        <path d="M37 10v8M37 56v8M10 37h8M56 37h8M18 18l6 6M56 56l-6-6M56 18l-6 6M18 56l6-6" stroke-opacity=".7"/>
        <circle cx="46" cy="28" r="2.4" fill="${goldB}" stroke="none"/><circle cx="28" cy="44" r="1.7" fill="${gold}" stroke="none"/></g>`,
    },
    {
      slug: 'dream',
      zh: '周公解夢',
      en: 'DREAM ORACLE',
      hot: false,
      desc: '夢境關鍵詞入典查釋，古籍原文對照今解。',
      svg: `<g class="glow-on-hover" stroke="${gold}" fill="none" stroke-width="1.2">
        <path d="M52 44a21 21 0 1 1-14-36 17 17 0 1 0 14 36z" stroke="${goldB}"/>
        <path d="M50 16l1.4 3.4 3.4 1.4-3.4 1.4-1.4 3.4-1.4-3.4-3.4-1.4 3.4-1.4z" fill="${gold}" stroke="none"/>
        <circle cx="58" cy="32" r="1.4" fill="${gold}" stroke="none"/></g>`,
    },
  ];

  // 导出到 window 方便子页 (arts/*.html) 复用
  window.FORTUNE_CARDS = CARDS;
  window.FORTUNE_GOLD = gold;
  window.FORTUNE_GOLD_BRIGHT = goldB;

  /* ---------- 在首页渲染 ---------- */
  const grid = document.getElementById('cardgrid');
  if (grid) {
    CARDS.forEach((c) => {
      const el = document.createElement('a');
      el.className = 'card';
      // 点击进入 SPA 排盘页 (hash 路由, 部署后从 /landing/ 跳到 /#/bazi)
      el.href = `/#/${c.slug}`;
      el.innerHTML = `
        ${c.hot ? '<span class="hot">熱門</span>' : ''}
        <div class="emblem"><svg viewBox="0 0 74 74">${c.svg}</svg></div>
        <h3>${c.zh}</h3><span class="card-en en">${c.en}</span>
        <p>${c.desc}</p>
        <div class="go"><span class="line"></span>立即排盤 BEGIN</div>`;
      grid.appendChild(el);
    });
  }
})();