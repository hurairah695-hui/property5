
const $=s=>document.querySelector(s);
const LABEL={house:'House',apartment:'Apartment',shop:'Shop',plot:'Plot'};
const HEART='<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 20.5s-7.5-4.6-9.2-9.4C1.7 7.8 3.6 4.5 7 4.5c2 0 3.5 1.1 5 3 1.5-1.9 3-3 5-3 3.4 0 5.3 3.3 4.2 6.6-1.7 4.8-9.2 9.4-9.2 9.4z" stroke-linejoin="round"/></svg>';
const USERS={'admin@example.com':['Admin@1234','admin','Demo Admin'],'buyer@example.com':['Buyer@1234','buyer','Demo Buyer'],'seller@example.com':['Seller@1234','seller','Demo Seller']};
const DEMO_SELLER='seller@example.com';
const U=(id,w=720)=>'https://images.unsplash.com/photo-'+id+'?auto=format&fit=crop&w='+w+'&q=72';
const IMG={
 house:['1613977257363-707ba9348227','1513584684374-8bab748fbf90','1600596542815-ffad4c1539a9','1706808849777-96e0d7be3bb7','1580587771525-78b9dba3b914','1721815693498-cc28507c0ba2','1628012209120-d9db7abf7eab'],
 apartment:['1525953776754-6c4b7ee655ab','1512845296467-183ccf124347','1764722870653-e59e737d1d30','1521208059781-bcf3fd4d1245','1672508061327-6efaa65896e9'],
 shop:['1764395294670-22fc367f3119','1772331274672-a5eecb4c6498','1761850648640-2ee5870ee883','1580554430120-94cfcb3adf25','1528698827591-e19ccd7bc23d'],
 plot:['1747854805840-9be7d5e360e6','1587745890135-20db8c79b027','1769258958976-8852440011b8','1629460455571-c943339c4f23'],
 liv:['1759691555105-17e609a3e46f','1759691554705-8a791e8f0875','1759691555285-74005fcf3ddf','1759691555010-7f3f8674d2f2','1759691555393-60cd5355d840'],
 bed:['1759691554836-81ba129a75b7','1759691554884-914bd85837c8','1759691337809-0ddaa66818de','1759691321555-94fed84288fa'],
 kit:['1759691554646-8155da2172ee','1759691337940-057d9cfce74c','1759691337936-ef702afd0714','1759691337957-ebc9ed54dc44'],
 lounge:['1759691555407-3c5834e6991e','1759691554837-be93ac47760b']};
const gal=(t,k)=>{const P=IMG[t],m=P[k%P.length];
  if(t==='house')return[m,IMG.liv[k%5],IMG.kit[k%4],IMG.bed[k%4]];
  if(t==='apartment')return[m,IMG.liv[(k+2)%5],IMG.bed[(k+1)%4],IMG.kit[(k+2)%4]];
  if(t==='shop')return[m,P[(k+2)%P.length],IMG.lounge[k%2]];
  return[m,P[(k+1)%P.length],P[(k+2)%P.length]]};
const PARA={
 house:'This well-maintained house offers comfortable family living with bright rooms, good ventilation and a practical layout. The neighbourhood is quiet and secure, close to schools, markets and mosques, with easy access to the main road.',
 apartment:'This apartment makes good use of its space with a smart layout and large windows. The building has security, a lift and dedicated parking, and daily needs such as shops, cafés and clinics are within a short walk.',
 shop:'This commercial unit has a visible position with steady walk-in traffic, which makes it a good fit for retail, a showroom, a clinic or a small office. Parking is nearby and the road is easy to reach.',
 plot:'This plot is clearly demarcated and ready for construction or use, with utilities close by. The area is well developed with metalled roads and a good mix of existing buildings, so it keeps growing steadily.'};
const longOf=p=>[p.description,PARA[p.type],p.feats.length>1?'Highlights include '+p.feats.slice(0,-1).join(', ').toLowerCase()+' and '+p.feats[p.feats.length-1].toLowerCase()+'.':'',
  p.mode==='rent'?'It is offered for rent at '+money(p.price)+' per month with a minimum stay of '+p.months+' months. The owner is happy to discuss a longer term, so tell us how many months you need when you request a meeting.':'It is offered for sale. '+(p.neg?'The asking price is negotiable for serious buyers after a viewing.':'The price is fixed by the owner.')+' Documents are ready for a quick and smooth transfer.'].filter(Boolean).join('\n\n');
const ROWS=[["Modern 10 Marla House, Bahria Town", "house", "sale", 38500000, 1, 0, "Rawalpindi", "Bahria Town Phase 7", "10 Marla", 5, 4, "Double-storey home with a front lawn, modular kitchen and covered parking.", ["Modular kitchen", "Front lawn", "Car porch for 2 cars", "Servant quarter", "24/7 security"]], ["Corner Shop on Main Boulevard", "shop", "sale", 12500000, 1, 0, "Lahore", "Gulberg Main Boulevard", "450 sq ft", 0, 0, "Ground-floor corner shop with high footfall and a wide frontage.", ["Corner position", "Wide frontage", "Shutter and glass front", "Parking nearby"]], ["Residential Plot, DHA Phase 2", "plot", "sale", 9500000, 0, 0, "Islamabad", "DHA Phase 2", "1 Kanal", 0, 0, "Ready-to-build plot on a 60 ft road with all utilities nearby.", ["Possession available", "60 ft road", "Gas and electricity nearby", "Close to park"]], ["2-Bed Apartment, F-11 Markaz", "apartment", "sale", 21000000, 1, 0, "Islamabad", "F-11 Markaz", "1,150 sq ft", 2, 2, "Bright apartment with a balcony, lift and 24/7 security.", ["Balcony", "Lift", "Covered parking", "Backup power", "Tiled floors"]], ["5 Marla Family Home, Johar Town", "house", "sale", 17500000, 1, 0, "Lahore", "Johar Town Block C", "5 Marla", 3, 3, "Neat family home in a quiet gated society close to schools.", ["Gated society", "Tiled flooring", "Marble kitchen counters", "Close to schools"]], ["Commercial Plot near Motorway", "plot", "sale", 28000000, 1, 0, "Rawalpindi", "Near M-2 Interchange", "8 Marla", 0, 0, "Corner commercial plot with easy motorway access.", ["Corner plot", "Commercial zone", "Easy motorway access", "Possession available"]], ["Luxury 1 Kanal Villa, F-7", "house", "sale", 120000000, 1, 0, "Islamabad", "F-7/2", "1 Kanal", 6, 6, "Spacious villa with a home theatre, garden and servant quarters.", ["Home theatre", "Landscaped garden", "Servant quarters", "Imported fittings", "Smart security"]], ["Furnished Studio Apartment, Gulberg", "apartment", "rent", 65000, 1, 6, "Lahore", "Gulberg III", "520 sq ft", 1, 1, "Compact, fully furnished studio close to offices and cafés.", ["Fully furnished", "Air conditioning", "Internet ready", "Gated building"]], ["Shop in Saddar Bazaar", "shop", "sale", 7200000, 1, 0, "Rawalpindi", "Saddar Bazaar", "220 sq ft", 0, 0, "Busy bazaar location, ideal for clothing or electronics.", ["Busy bazaar", "Steel shutter", "Electricity meter", "Near metro station"]], ["Corner Plot, Gulberg Greens", "plot", "sale", 6500000, 1, 0, "Islamabad", "Gulberg Greens", "5 Marla", 0, 0, "Park-facing corner plot in a developed block.", ["Park facing", "Corner plot", "Developed block", "Clear title"]], ["Modern Home with Front Lawn, Bahria Enclave", "house", "sale", 28500000, 1, 0, "Islamabad", "Bahria Enclave Sector A", "8 Marla", 4, 4, "Contemporary design with a large front lawn and a double-height lounge.", ["Double-height lounge", "Front lawn", "Wooden doors", "Modular kitchen", "Solar-ready roof"]], ["Apartment with Balcony for Rent, DHA", "apartment", "rent", 120000, 1, 12, "Lahore", "DHA Phase 5", "950 sq ft", 2, 2, "Modern apartment with a balcony, parking and gated security.", ["Balcony", "Reserved parking", "Gated security", "Lift", "Backup power"]], ["4-Bed House for Rent, Bahria Town", "house", "rent", 180000, 1, 12, "Rawalpindi", "Bahria Town Phase 4", "10 Marla", 4, 4, "Spacious family house with a lawn and car porch, ready to move in.", ["Lawn", "Car porch", "Bright rooms", "Separate drawing room", "Gas available"]], ["3-Bed Luxury Apartment, Clifton", "apartment", "sale", 58000000, 1, 0, "Karachi", "Clifton Block 5", "2,100 sq ft", 3, 3, "High-floor apartment with sea breeze, gym and covered parking.", ["Sea breeze", "Gym and lobby", "Covered parking", "Backup generator", "24/7 security"]], ["Ground Floor Shop for Rent, Blue Area", "shop", "rent", 250000, 1, 24, "Islamabad", "Jinnah Avenue, Blue Area", "600 sq ft", 0, 0, "Prime ground-floor shop on the main avenue, ready for retail or a showroom.", ["Prime avenue", "Glass frontage", "Air conditioned", "Loading access"]], ["Residential Plot, Bahria Town Phase 8", "plot", "sale", 7200000, 1, 0, "Rawalpindi", "Bahria Town Phase 8", "10 Marla", 0, 0, "Level plot in a developed sector with parks and mosques nearby.", ["Developed sector", "Possession available", "Near park", "Near mosque"]], ["7 Marla Modern House, Wapda Town", "house", "sale", 32000000, 1, 0, "Lahore", "Wapda Town Phase 1", "7 Marla", 5, 5, "Brand-new modern house with imported tiles and a stylish elevation.", ["Brand new", "Imported tiles", "Stylish elevation", "Modular kitchen", "Car porch"]], ["1-Bed Furnished Apartment for Rent, Gulberg III", "apartment", "rent", 85000, 0, 6, "Lahore", "Gulberg III", "700 sq ft", 1, 1, "Fully furnished one-bedroom with a city view, available immediately.", ["Fully furnished", "City view", "Lift", "Covered parking"]], ["Showroom on Canal Road", "shop", "sale", 45000000, 1, 0, "Faisalabad", "Canal Road", "1,200 sq ft", 0, 0, "Large showroom with a double-height ceiling on a busy road.", ["Double-height ceiling", "Main road", "Basement storage", "Ample parking"]], ["Corner Plot, DHA Phase 6", "plot", "sale", 38000000, 1, 0, "Lahore", "DHA Phase 6", "1 Kanal", 0, 0, "Corner plot on a wide road, ideal for a custom-built home.", ["Corner plot", "Wide road", "Developed block", "Possession available"]], ["Double-Storey Home, Hayatabad", "house", "sale", 24000000, 0, 0, "Peshawar", "Hayatabad Phase 3", "6 Marla", 4, 3, "Well-kept double-storey home in a calm, popular neighbourhood.", ["Well maintained", "Near market", "Gas available", "Marble flooring"]], ["Sea-View Apartment, Bahria Town Karachi", "apartment", "sale", 36000000, 1, 0, "Karachi", "Bahria Town Precinct 10", "1,650 sq ft", 3, 3, "Spacious apartment with a sea-facing balcony and resort-style amenities.", ["Sea-facing balcony", "Clubhouse access", "Swimming pool", "Covered parking"]], ["Furnished Villa for Rent, F-10", "house", "rent", 350000, 1, 12, "Islamabad", "F-10/3", "1 Kanal", 5, 5, "Fully furnished villa with a garden, ideal for families or diplomats.", ["Fully furnished", "Garden", "Servant quarter", "Central heating", "Car porch"]], ["Farmhouse Plot, Sheikhupura Road", "plot", "sale", 22000000, 1, 0, "Lahore", "Sheikhupura Road", "4 Kanal", 0, 0, "Open farmhouse plot with green surroundings, a short drive from the city.", ["Green surroundings", "Farmhouse zone", "Tube-well possible", "Clear title"]], ["Corner Shop for Rent, Johar Town Market", "shop", "rent", 95000, 1, 12, "Lahore", "Johar Town Commercial", "300 sq ft", 0, 0, "Corner shop in a busy commercial market with steady customers.", ["Corner shop", "Busy market", "Shutter front", "Electricity meter"]], ["Penthouse with Terrace, E-11", "apartment", "sale", 78000000, 1, 0, "Islamabad", "E-11/2", "3,400 sq ft", 4, 4, "Top-floor penthouse with a private terrace and mountain views.", ["Private terrace", "Mountain view", "Two parking spots", "Lift access", "Smart home wiring"]], ["Open Plot for Rent, I-9 Industrial Area", "plot", "rent", 120000, 1, 12, "Islamabad", "I-9 Industrial Area", "1 Kanal", 0, 0, "Fenced open plot suitable for parking, storage or a workshop.", ["Fenced boundary", "Heavy vehicle access", "Electricity nearby", "Flexible use"]], ["Brand-New 3-Bed House, Citi Housing", "house", "sale", 19500000, 0, 0, "Faisalabad", "Citi Housing", "5 Marla", 3, 3, "Newly built house with a modern design in a gated housing society.", ["Newly built", "Gated society", "Modern design", "Tiled flooring"]]];
const _k={};
const SEEDP=ROWS.map((r,i)=>{const [title,type,mode,price,neg,months,city,locality,area_size,beds,baths,description,feats]=r,k=_k[type]=(_k[type]??-1)+1;
  const p={id:i+1,seed:1,owner:DEMO_SELLER,title,type,mode,price,neg:!!neg,months:months||null,city,locality,area_size,beds:beds||null,baths:baths||null,description,feats,ids:gal(type,k)};p.long=longOf(p);return p});
const nPics=p=>p.ids?p.ids.length:(p.images?p.images.length:0);
const pic=(p,i,w)=>p.ids?U(p.ids[i],w):p.images[i];
function loadProps(){const gone=S.get('pd5_deleted',[]);
  return [...S.get('pd2_props',[]).map(p=>({...p,mode:p.mode||'sale',images:p.images||(p.image?[p.image]:[])})),...SEEDP.filter(p=>!gone.includes(p.id))]}

/* storage (safe if blocked) */
const S={get(k,d){try{const v=localStorage.getItem(k);return v?JSON.parse(v):d}catch{return d}},set(k,v){try{localStorage.setItem(k,JSON.stringify(v));return true}catch{return false}}};
let me=null,props=[],favs=[],type='all',q='',favOnly=false,photo=null,tt;

const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
function money(n){n=+n;const t=v=>v.toFixed(2).replace(/\.?0+$/,'');
  if(n>=1e7)return 'PKR '+t(n/1e7)+' Crore';if(n>=1e5)return 'PKR '+t(n/1e5)+' Lakh';return 'PKR '+n.toLocaleString('en-PK')}
function toast(m){const t=$('#toast');t.textContent=m;t.classList.add('show');clearTimeout(tt);tt=setTimeout(()=>t.classList.remove('show'),2600)}

/* illustrations for listings without a photo */
const PAL=[['#BFE3F5','#F4F9FC','#F2E8D5','#B5533C','#8CC084'],['#FAD9C1','#FDF3E8','#E6EEF5','#2F5D8A','#9CCB86'],['#CDE7E0','#F3FAF7','#F7EBD0','#7A4B8C','#7DB77A'],['#D8DDF5','#F6F7FD','#EFE3DA','#2E6F66','#A5CF8A']];
function art(t,id){
  const [s1,s2,w,r,g]=PAL[id%4];let b='';
  if(t==='house')b=`<rect x="112" y="140" width="176" height="92" fill="${w}"/><polygon points="96,144 200,68 304,144" fill="${r}"/><rect x="252" y="82" width="20" height="40" fill="${r}" opacity=".8"/><rect x="186" y="176" width="28" height="56" fill="#34495E"/><rect x="130" y="162" width="42" height="34" fill="#CFE8F6"/><rect x="228" y="162" width="42" height="34" fill="#CFE8F6"/><rect x="334" y="196" width="8" height="40" fill="#6B4A32"/><circle cx="338" cy="186" r="28" fill="#5FA36A"/>`;
  else if(t==='apartment'){let k='';for(let y=0;y<5;y++)for(let x=0;x<3;x++)k+=`<rect x="${148+x*38}" y="${58+y*32}" width="22" height="20" fill="${(x+y)%3?'#CFE8F6':'#FFE08A'}"/>`;
    b=`<rect x="64" y="120" width="64" height="112" fill="${r}" opacity=".75"/><rect x="132" y="38" width="136" height="194" fill="${w}"/>${k}<rect x="184" y="196" width="32" height="36" fill="#34495E"/><rect x="272" y="150" width="64" height="82" fill="${r}" opacity=".75"/>`}
  else if(t==='shop'){let a='';for(let i=0;i<8;i++)a+=`<rect x="${70+i*32.5}" y="116" width="32.5" height="34" fill="${i%2?'#FFFFFF':r}"/>`;
    b=`<rect x="70" y="116" width="260" height="116" fill="${w}"/>${a}<rect x="96" y="164" width="130" height="68" fill="#CFE8F6"/><rect x="246" y="170" width="52" height="62" fill="#34495E"/><rect x="150" y="82" width="100" height="26" rx="4" fill="${r}"/><text x="200" y="101" font-family="sans-serif" font-size="16" font-weight="700" fill="#fff" text-anchor="middle">SHOP</text>`}
  else b=`<polygon points="30,238 370,238 336,176 64,176" fill="#7FB36F"/><polygon points="30,238 370,238 336,176 64,176" fill="none" stroke="#fff" stroke-width="3" stroke-dasharray="8 6"/><circle cx="30" cy="238" r="5" fill="${r}"/><circle cx="370" cy="238" r="5" fill="${r}"/><circle cx="336" cy="176" r="5" fill="${r}"/><circle cx="64" cy="176" r="5" fill="${r}"/><rect x="196" y="122" width="6" height="84" fill="#6B4A32"/><rect x="146" y="98" width="106" height="38" rx="5" fill="${r}"/><text x="199" y="123" font-family="sans-serif" font-size="14" font-weight="700" fill="#fff" text-anchor="middle">FOR SALE</text><circle cx="42" cy="196" r="20" fill="#5FA36A"/><circle cx="364" cy="198" r="16" fill="#5FA36A"/>`;
  const svg=`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300"><defs><linearGradient id="a" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${s1}"/><stop offset="1" stop-color="${s2}"/></linearGradient></defs><rect width="400" height="300" fill="url(#a)"/><circle cx="335" cy="55" r="26" fill="#FFE9A8"/><rect y="232" width="400" height="68" fill="${g}"/>${b}</svg>`;
  return 'data:image/svg+xml;charset=utf-8,'+encodeURIComponent(svg)}

/* ===== phase 3: accounts, sessions, meetings, browse UI, 3D ===== */
const HOME={seller:'seller.html',buyer:'buyer.html',admin:'buyer.html'};
const allUsers=()=>({...USERS,...S.get('pd3_users',{})});
function session(){try{return JSON.parse(sessionStorage.getItem('pd_user')||localStorage.getItem('pd_user')||'null')}catch{return null}}
function validSession(){const u=session(),a=u&&allUsers()[u.email];return a&&a[1]===u.role?u:null}
function signIn(u,remember){const j=JSON.stringify(u);try{(remember?localStorage:sessionStorage).setItem('pd_user',j)}catch{}location.href=HOME[u.role]}
function signOut(){try{localStorage.removeItem('pd_user');sessionStorage.removeItem('pd_user')}catch{}location.href='index.html'}
function need(roles){const u=validSession();if(!u||!roles.includes(u.role)){location.href=u?HOME[u.role]:'index.html';throw new Error('redirecting')}return u}
addEventListener('error',e=>{if(e.message&&e.message.includes('redirecting'))e.preventDefault()});  // expected when a page sends you elsewhere
const getM=()=>S.get('pd3_meetings',[]),setM=m=>S.set('pd3_meetings',m);
const pName=e=>(allUsers()[e]||[,,'Seller'])[2];
const fmtDate=d=>new Date(d+'T00:00').toLocaleDateString('en-GB',{weekday:'short',day:'numeric',month:'short',year:'numeric'});
let mine=false;

/* ===== phase 7: limited-time deal (rotates every OFFER.hours on the clock) + buyer hero slideshow ===== */
const OFFER={hours:6,pct:10,count:6};
let _o=null;
function offer(){
  const now=Date.now();if(_o&&now<_o.end)return _o;
  const H=OFFER.hours*36e5,off=new Date().getTimezoneOffset()*6e4,b=Math.floor((now-off)/H),sale=SEEDP.filter(p=>p.mode==='sale').map(p=>p.id),k=(b*3)%sale.length;
  return _o={end:(b+1)*H+off,ids:Array.from({length:OFFER.count},(_,i)=>sale[(k+i)%sale.length])}}
const dealPrice=p=>{if(!me||me.role==='seller'||p.mode==='rent'||!p.seed)return null;return offer().ids.includes(p.id)?Math.round(p.price*(100-OFFER.pct)/100/1000)*1000:null};
const priceHtml=p=>{const dp=dealPrice(p);return dp?`<div class="pr">${money(dp)} <s>${money(p.price)}</s></div>`:`<div class="pr">${money(p.price)}${p.mode==='rent'?'<small> /month</small>':''}</div>`};
const dealBadge=p=>dealPrice(p)?`<span class="dbadge">${OFFER.pct}% OFF</span>`:'';
let dealOnly=false;
/* scrolling offers line above the hero */
function ticker(){
  const t=$('#tk');if(!t)return;
  const M=['🎉 10% off on your first purchase','⚡ Exclusive offer: limited-time deals on selected properties','🏡 New listings added every day','🔑 Buy or rent: houses, apartments, shops and plots','📅 Request a meeting with the seller in one tap','💬 Many prices are negotiable'];
  const one=c=>`<div class="tg"${c?' aria-hidden="true"':''}>${M.map(m=>`<span>${m}</span>`).join('')}</div>`;
  t.innerHTML=one('')+one(1);
  const fit=()=>t.style.setProperty('--dur',Math.max(18,t.scrollWidth/2/80).toFixed(1)+'s');   // ~80 px per second
  fit();if(document.fonts)document.fonts.ready.then(fit)}
function heroDeals(onNew){
  const reduce=matchMedia('(prefers-reduced-motion: reduce)').matches,picks=[1,7,11,14,22].map(id=>SEEDP.find(p=>p.id===id));
  const box=$('#slides'),dots=$('#dots'),cap=$('#scap');
  box.innerHTML=picks.map((_,i)=>`<div class="sl" data-i="${i}"></div>`).join('');
  dots.innerHTML=picks.map((_,i)=>`<button type="button" role="tab" aria-label="Show photo ${i+1}" data-i="${i}" aria-selected="false"></button>`).join('');
  const sl=[...box.children],bt=[...dots.children],ready={};let cur=-1,timer,hov=false;
  const load=i=>ready[i]||(ready[i]=new Promise(ok=>{const im=new Image(),u=pic(picks[i],0,1600);im.onload=()=>{sl[i].style.backgroundImage=`url("${u}")`;ok(true)};im.onerror=()=>ok(false);im.src=u}));
  async function show(i,n=0){
    i=(i+picks.length)%picks.length;if(i===cur)return;
    if(!await load(i))return n<picks.length?show(i+1,n+1):0;                       // skip a photo that cannot load
    sl.forEach((s,k)=>s.classList.toggle('on',k===i));bt.forEach((b,k)=>b.setAttribute('aria-selected',k===i));cur=i;
    const p=picks[i],dp=dealPrice(p);cap.href='property.html?id='+p.id;
    cap.innerHTML=`<b>${esc(p.title)}</b><span>${esc(p.city)} · ${money(dp||p.price)}${dp?' · '+OFFER.pct+'% off':''}</span>`;load((i+1)%picks.length)}
  const play=()=>{clearInterval(timer);if(!reduce&&!document.hidden&&!hov)timer=setInterval(()=>show(cur+1),3000)};
  dots.onclick=e=>{const b=e.target.closest('button');if(b){show(+b.dataset.i);play()}};
  const hero=$('#hero');hero.addEventListener('mouseenter',()=>{hov=true;clearInterval(timer)});hero.addEventListener('mouseleave',()=>{hov=false;play()});
  document.addEventListener('visibilitychange',play);
  show(0);play();
  /* countdown */
  const pad=n=>String(n).padStart(2,'0'),dh=$('#dh'),dm=$('#dm'),ds=$('#ds');
  $('#dtxt').innerHTML=`<b>${OFFER.pct}% off</b> on ${OFFER.count} selected properties. Ends in`;
  let end=offer().end;
  function tick(){const now=Date.now();
    if(now>=end){_o=null;end=offer().end;if(onNew)onNew();toast('New deals are live')}    // cycle ended: new deals, refresh the cards
    const s=Math.max(0,Math.floor((end-now)/1000));dh.textContent=pad(Math.floor(s/3600));dm.textContent=pad(Math.floor(s%3600/60));ds.textContent=pad(s%60)}
  tick();setInterval(tick,1000);
  $('#dbtn').onclick=()=>{const c=document.querySelector('.chip[data-f=deal]');if(c&&c.getAttribute('aria-pressed')!=='true')c.click();document.querySelector('.fbar').scrollIntoView({behavior:reduce?'auto':'smooth',block:'start'})}}

let modeF='all';
const LOGO=`<svg viewBox="0 0 40 40" aria-hidden="true"><defs><linearGradient id="lgA" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3B82F6"/><stop offset="1" stop-color="#12305A"/></linearGradient><linearGradient id="lgB" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#F3D58A"/><stop offset="1" stop-color="#C79A3B"/></linearGradient></defs><rect width="40" height="40" rx="11" fill="url(#lgA)"/><path d="M8.5 20.5 20 10l11.5 10.5" fill="none" stroke="url(#lgB)" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/><path d="M12.5 19.5V30h15V19.5" fill="none" stroke="#fff" stroke-width="2.4" stroke-linejoin="round"/><rect x="17.2" y="22.5" width="5.6" height="7.5" rx="1.2" fill="url(#lgB)"/></svg><span class="bn">Prop<em>Deal</em><small>Real estate</small></span>`;
function nav(){
  const a=$('#av'),m=$('#menu'),shut=()=>{m.hidden=true;a.setAttribute('aria-expanded','false')};
  $('#who').textContent=me.name;$('#mail').textContent=me.email;$('#rl').textContent=me.role;a.textContent=me.name[0].toUpperCase();
  const b=$('.brand');if(b.tagName==='A')b.href=HOME[me.role];
  a.onclick=e=>{e.stopPropagation();const o=m.hidden;m.hidden=!o;a.setAttribute('aria-expanded',String(o))};
  document.addEventListener('click',e=>{if(!m.contains(e.target))shut()});addEventListener('keydown',e=>{if(e.key==='Escape')shut()});
  $('#out').onclick=signOut}
const sizeLine=p=>[p.area_size&&`<span>${esc(p.area_size)}</span>`,p.beds!=null&&`<span>${p.beds} beds</span>`,p.baths!=null&&`<span>${p.baths} baths</span>`].filter(Boolean).join('');
const negPill=p=>p.neg===true?'<span class="pill neg">Negotiable</span>':p.neg===false?'<span class="pill fix">Fixed</span>':'';
function card(p,i){
  const own=me.role==='seller'&&p.owner===me.email,fav=favs.includes(p.id),rent=p.mode==='rent',src=nPics(p)?pic(p,0,560):art(p.type,p.id);
  return `<article class="card tilt" data-open="${p.id}" tabindex="0" role="link" aria-label="${esc(p.title)}" style="--i:${Math.min(i,12)}"><div class="ph"><img src="${src}" data-t="${p.type}" data-id="${p.id}" alt="" loading="lazy" decoding="async">
    <span class="tag${rent?' rent':''}">${rent?'For Rent':'For Sale'}</span>${dealBadge(p)}
    <button class="heart${fav?' on':''}" data-id="${p.id}" aria-pressed="${fav}" aria-label="Save to favourites">${HEART}</button></div>
    <div class="bd"><p class="kind">${LABEL[p.type]} for ${rent?'rent':'sale'}</p><h3>${esc(p.title)}</h3><p class="loc">${esc([p.locality,p.city].filter(Boolean).join(', '))}</p>
    <p class="ds">${esc(p.description||'')}</p><div class="meta">${sizeLine(p)}</div>
    <div class="cf">${priceHtml(p)}${negPill(p)}</div>
    ${own?`<button class="del" data-del="${p.id}">Delete listing</button>`:''}</div></article>`}
function render(){
  const list=props.filter(p=>(type==='all'||p.type===type)&&(modeF==='all'||(p.mode||'sale')===modeF)&&(!favOnly||favs.includes(p.id))&&(!dealOnly||dealPrice(p))&&(!mine||p.owner===me.email)&&(!q||(p.title+' '+p.city+' '+(p.locality||'')).toLowerCase().includes(q)));
  $('#count').textContent=list.length+(list.length===1?' property':' properties');
  const g=$('#grid');g.innerHTML=list.length?list.map(card).join(''):'<div class="empty">Nothing matches these filters. Try another filter or search.</div>';
  if(!render.done){render.done=1;g.classList.add('first');setTimeout(()=>g.classList.remove('first'),1300)}}
const rentTxt=m=>m.months?` · rental for ${m.months} month${m.months>1?'s':''}`:'';
const goto=id=>{location.href='property.html?id='+id};
function browse(){
  const ch=(a,k,l,on)=>`<button class="chip" ${a}="${k}" aria-pressed="${on}">${l}</button>`;
  $('#chips').innerHTML=[['all','All'],['house','Houses'],['apartment','Apartments'],['shop','Shops'],['plot','Plots']].map(([k,l])=>ch('data-k',k,l,k==='all')).join('')
    +'<span class="csep"></span>'+ch('data-m','sale','For Sale',false)+ch('data-m','rent','For Rent',false)+'<span class="csep"></span>'+ch('data-f','fav','♥ Favourites',false)+(me.role==='seller'?ch('data-f','mine','My listings',false):ch('data-f','deal','🔥 Deals',false));
  $('#chips').addEventListener('click',e=>{const c=e.target.closest('.chip');if(!c)return;const d=c.dataset;
    if(d.k){type=d.k;document.querySelectorAll('.chip[data-k]').forEach(x=>x.setAttribute('aria-pressed',x===c))}
    else if(d.m){modeF=modeF===d.m?'all':d.m;document.querySelectorAll('.chip[data-m]').forEach(x=>x.setAttribute('aria-pressed',x.dataset.m===modeF))}
    else if(d.f==='fav'){favOnly=!favOnly;c.setAttribute('aria-pressed',favOnly)}
    else if(d.f==='deal'){dealOnly=!dealOnly;c.setAttribute('aria-pressed',dealOnly)}
    else{mine=!mine;c.setAttribute('aria-pressed',mine)}
    render()});
  let t;$('#q').addEventListener('input',e=>{clearTimeout(t);const v=e.target.value.trim().toLowerCase();t=setTimeout(()=>{q=v;render()},150)});
  $('#grid').addEventListener('click',e=>{
    const h=e.target.closest('.heart');
    if(h){e.stopPropagation();const id=+h.dataset.id,on=!favs.includes(id);favs=on?[...favs,id]:favs.filter(x=>x!==id);S.set('pd2_favs_'+me.email,favs);
      h.classList.toggle('on',on);h.setAttribute('aria-pressed',on);if(favOnly)render();return}
    const d=e.target.closest('[data-del]');
    if(d){if(confirm('Delete this listing?')){const id=+d.dataset.del;
      if(id<=SEEDP.length){S.set('pd5_deleted',[...S.get('pd5_deleted',[]),id])}else{S.set('pd2_props',S.get('pd2_props',[]).filter(x=>x.id!==id))}
      props=loadProps();render();toast('Listing deleted')}return}
    const c=e.target.closest('[data-open]');if(c)goto(c.dataset.open)});
  $('#grid').addEventListener('keydown',e=>{if(e.key==='Enter'&&e.target.matches('[data-open]'))goto(e.target.dataset.open)});
  tilt($('#grid'));render()}
function tabs(renderM){document.querySelectorAll('.tab').forEach(b=>b.onclick=()=>{
  document.querySelectorAll('.tab').forEach(x=>x.setAttribute('aria-selected',x===b));
  const m=b.dataset.v==='m';$('#vB').hidden=m;$('#vM').hidden=!m;if(m)renderM()})}
function tilt(root){let f=0,ev=null;
  root.addEventListener('pointermove',e=>{if(e.pointerType==='touch')return;ev=e;if(f)return;
    f=requestAnimationFrame(()=>{f=0;const c=ev.target.closest&&ev.target.closest('.tilt');if(!c)return;
      const r=c.getBoundingClientRect(),x=(ev.clientX-r.left)/r.width,y=(ev.clientY-r.top)/r.height;
      c.style.setProperty('--mx',x*100+'%');c.style.setProperty('--my',y*100+'%');
      c.style.transform=`perspective(900px) rotateY(${(x-.5)*9}deg) rotateX(${(.5-y)*7}deg) translateZ(6px)`})});
  root.addEventListener('pointerout',e=>{const c=e.target.closest('.tilt');if(c&&!c.contains(e.relatedTarget))c.style.transform=''})}
document.addEventListener('error',e=>{const i=e.target;if(i&&i.tagName==='IMG'&&i.dataset.t&&!i.dataset.fb){i.dataset.fb='1';i.src=art(i.dataset.t,+i.dataset.id)}},true);
/* ===== phase 5: validation helpers + subtle particle background ===== */
const RX_EMAIL=/^[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$/;
const vReq=(v,l,min,max)=>{v=(v||'').trim();return !v?`${l} is required.`:v.length<min?`${l} must be at least ${min} characters.`:v.length>max?`${l} must be ${max} characters or fewer.`:''};
const vEmail=v=>{v=(v||'').trim();return !v?'Email is required.':!v.includes('@')?'Email must contain the @ symbol.':!RX_EMAIL.test(v)?'Enter a valid email, like name@example.com.':''};
const vPass=(v,strong)=>{if(!v)return 'Password is required.';if(v.length<6)return 'Password must be at least 6 characters.';
  if(strong){if(!/[a-z]/.test(v))return 'Add at least one lowercase letter.';if(!/[A-Z]/.test(v))return 'Add at least one uppercase letter.';if(!/\d/.test(v))return 'Add at least one number.';if(!/[^A-Za-z0-9]/.test(v))return 'Add at least one special character (like @ or #).'}return ''};
const vName=v=>{v=(v||'').trim();return !v?'Full name is required.':!/^\p{L}[\p{L} .'-]{1,49}$/u.test(v)?'Use letters only (2 to 50 characters).':''};
const vAge=v=>{v=(v||'').trim();if(!v)return 'Age is required.';if(!/^\d+$/.test(v))return 'Age must be a whole number.';const n=+v;return n<18?'You must be at least 18 years old.':n>100?'Enter a valid age (18 to 100).':''};
const vNum=(v,l,min,max,opt)=>{v=(v||'').trim();if(!v)return opt?'':`${l} is required.`;if(!/^\d+$/.test(v))return `${l} must be a number.`;const n=+v;return n<min?`${l} must be at least ${min}.`:n>max?`${l} must be ${max.toLocaleString('en-PK')} or less.`:''};
const vCity=v=>{v=(v||'').trim();return !v?'City is required.':!/^\p{L}[\p{L} .,'-]{1,79}$/u.test(v)?'Enter a valid city name (letters only).':''};
function showErr(i,msg){
  const a=i.closest('.ctl')||i;let e=a.nextElementSibling;if(e&&!e.classList.contains('ferr'))e=null;
  if(msg){if(!e){e=document.createElement('div');e.className='ferr';e.setAttribute('role','alert');a.after(e)}e.textContent=msg}else if(e)e.remove();
  i.classList.toggle('bad',!!msg);i.setAttribute('aria-invalid',msg?'true':'false');return !msg}
function shake(i){i.classList.remove('shk');void i.offsetWidth;i.classList.add('shk')}
function watch(i,fn){let t=0;const run=()=>showErr(i,fn(i.value));
  i.addEventListener('blur',()=>{t=1;run()});i.addEventListener('input',()=>{if(t)run()});
  return()=>{t=1;const ok=run();if(!ok)shake(i);return ok}}
function digits(i,max){
  i.addEventListener('keydown',e=>{if(e.key.length===1&&!/\d/.test(e.key)&&!e.ctrlKey&&!e.metaKey&&!e.altKey)e.preventDefault()});
  i.addEventListener('input',()=>{const v=i.value.replace(/\D+/g,'').slice(0,max);if(v!==i.value)i.value=v})}
function clearErrs(f){f.querySelectorAll('.ferr').forEach(e=>e.remove());f.querySelectorAll('.bad').forEach(e=>{e.classList.remove('bad');e.removeAttribute('aria-invalid')})}


/* subtle particle layer (light on CPU): sits above the page background and below all content */
function particles(){
  if(document.getElementById('bgfx'))return;
  const cv=document.createElement('canvas');cv.id='bgfx';cv.setAttribute('aria-hidden','true');document.body.prepend(cv);
  const x=cv.getContext('2d'),rm=matchMedia('(prefers-reduced-motion: reduce)').matches,COL=['77,163,255','77,163,255','124,196,255','199,154,59'];
  const small=innerWidth<700||(navigator.hardwareConcurrency||4)<=4;
  let W=0,H=0,P=[],m={x:-1e4,y:-1e4,on:false},last=0,raf=0,scrolling=0,st;
  const make=()=>{const a=Math.random()*6.283,s=.12+Math.random()*.2;return{x:Math.random()*W,y:Math.random()*H,bx:Math.cos(a)*s,by:Math.sin(a)*s,vx:Math.cos(a)*s,vy:Math.sin(a)*s,r:.9+Math.random()*1.4,c:COL[Math.random()*COL.length|0]}};
  function size(){W=innerWidth;H=innerHeight;const D=Math.min(devicePixelRatio||1,1.25);cv.width=W*D;cv.height=H*D;x.setTransform(D,0,0,D,0,0);
    const n=Math.max(18,Math.min(small?26:44,Math.round(W*H/34000)));while(P.length<n)P.push(make());P.length=Math.min(P.length,n);P.forEach(p=>{p.x=Math.min(p.x,W);p.y=Math.min(p.y,H)})}
  function step(dt){
    x.clearRect(0,0,W,H);x.lineWidth=1;
    for(const p of P){
      if(m.on){const dx=p.x-m.x,dy=p.y-m.y,d2=dx*dx+dy*dy;if(d2<16900&&d2>1){const d=Math.sqrt(d2),f=(1-d/130)*.05*dt;p.vx+=dx/d*f;p.vy+=dy/d*f}}
      p.vx+=(p.bx-p.vx)*.02*dt;p.vy+=(p.by-p.vy)*.02*dt;p.x+=p.vx*dt;p.y+=p.vy*dt;
      if(p.x<-10)p.x=W+10;else if(p.x>W+10)p.x=-10;if(p.y<-10)p.y=H+10;else if(p.y>H+10)p.y=-10}
    for(let i=0;i<P.length;i++){const a=P[i];
      if(!small)for(let k=i+1;k<P.length;k++){const b=P[k],dx=a.x-b.x,dy=a.y-b.y,d2=dx*dx+dy*dy;
        if(d2<9000){x.strokeStyle=`rgba(77,163,255,${(1-Math.sqrt(d2)/95)*.15})`;x.beginPath();x.moveTo(a.x,a.y);x.lineTo(b.x,b.y);x.stroke()}}
      if(m.on){const dx=a.x-m.x,dy=a.y-m.y,d2=dx*dx+dy*dy;if(d2<16900){x.strokeStyle=`rgba(124,196,255,${(1-Math.sqrt(d2)/130)*.35})`;x.beginPath();x.moveTo(a.x,a.y);x.lineTo(m.x,m.y);x.stroke()}}
      x.fillStyle=`rgba(${a.c},.55)`;x.beginPath();x.arc(a.x,a.y,a.r,0,6.283);x.fill()}}
  const loop=t=>{raf=requestAnimationFrame(loop);if(scrolling||t-last<30)return;const dt=Math.min(3,(t-last)/16.67);last=t;step(dt)};   // ~33 fps, paused while scrolling
  size();if(rm)step(0);else raf=requestAnimationFrame(loop);
  let rt;addEventListener('resize',()=>{clearTimeout(rt);rt=setTimeout(()=>{size();if(rm)step(0)},150)});
  if(!rm){const mv=e=>{m.x=e.clientX;m.y=e.clientY;m.on=true},off=()=>{m.on=false};
    addEventListener('pointermove',mv,{passive:true});addEventListener('pointerdown',mv,{passive:true});
    addEventListener('pointerup',e=>{if(e.pointerType==='touch')off()});addEventListener('pointercancel',off);document.addEventListener('mouseleave',off);addEventListener('blur',off);
    addEventListener('scroll',()=>{scrolling=1;clearTimeout(st);st=setTimeout(()=>scrolling=0,140)},{passive:true})}
  document.addEventListener('visibilitychange',()=>{cancelAnimationFrame(raf);if(!document.hidden&&!rm){last=performance.now();raf=requestAnimationFrame(loop)}})}
particles();
document.querySelectorAll('.brand').forEach(b=>b.innerHTML=LOGO);
