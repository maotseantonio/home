import{E as s,a as r}from"./ExtMessage-a2aff225.js";import"./onMessage-fb148085.js";async function f(){return(await chrome.tabs.query({status:"complete",windowType:"normal",url:"https://my.mangapin.com/*",currentWindow:!0}))[0]}async function R(e,t){var g;const{url:a,site:n}=e,c=e.sameTab&&t?await chrome.tabs.update(t,{url:a}):await chrome.tabs.create({url:a}),o=(g=p(a))==null?void 0:g.hostname;if(!o||c.id===void 0)return;let i;if(n){const m=(d,y,w)=>{if(d!==w.id)return;const l=p(y.url);if(!l)return i==null?void 0:i();if(l.hostname!==o)return s.send({app:!0,event:"main:app:onSiteRedirect",data:{siteId:n.id,newHost:l.hostname}}).then(h=>{h!=null&&h.site&&chrome.tabs.reload(d)}),i==null?void 0:i();y.status==="completed"&&(i==null||i())};i=()=>chrome.tabs.onUpdated.removeListener(m),chrome.tabs.onUpdated.addListener(m),setTimeout(i,25e3)}s.once({event:"content:main:getWebCommand",filter:m=>{var d;return m.tabId===c.id&&((d=p(m.tabUrl))==null?void 0:d.hostname)===o},handler(){return i==null||i(),e}})}function p(e,{removeTrailingSlash:t=!0}={}){if(!e)return;const a=t&&e.endsWith("/")?e.slice(0,-1):e;try{return new URL(a)}catch{return}}class u{static async setup(){chrome.notifications.onClicked.addListener(async t=>{chrome.notifications.clear(t);const[a,n]=t.split(" ");if(a&&n){const o=await s.send({app:!0,event:"main:app:getNextWebCommand",data:{siteId:a,titleId:n}});if(o){R(o);return}}const c=await f();c!=null&&c.id?chrome.tabs.highlight({tabs:c.index}):chrome.tabs.create({url:"https://my.mangapin.com"})})}static create(t){const a=[t.siteId,t.titleId].join(" ");chrome.notifications.clear(a),chrome.notifications.create(a,{title:t.title,message:t.message,imageUrl:t.imageUrl,iconUrl:chrome.runtime.getURL("/logo/icon32.png"),type:t.imageUrl?"image":"basic"})}static hide({siteId:t,titleId:a}){const n=[t,a].join(" ");chrome.notifications.clear(n)}static clear(){chrome.notifications.getAll(t=>{Object.keys(t).forEach(a=>{chrome.notifications.clear(a)})})}}async function E({siteId:e,rawPage:t,page:a}){if(!(t!=null&&t.data))return;const n=await f(),c=o=>s.send({tabId:o,event:"main:app:addEntry",data:{siteId:e,rawPage:t,page:a}});if(n!=null&&n.id)c(n==null?void 0:n.id),chrome.tabs.highlight({tabs:n.index});else{const{id:o}=await chrome.tabs.create({url:"https://my.mangapin.com"});if(o===void 0)return;s.once({event:"bridge:main:ready",filter:i=>i.tabId===o,handler:()=>{c(o)}})}}async function b(e){const t=await f();t!=null&&t.id?(s.send({tabId:t.id,event:"main:app:openEntry",data:{id:e}}),chrome.tabs.highlight({tabs:t.index})):chrome.tabs.create({url:`https://my.mangapin.com/entry/${e}`})}function N(){chrome.commands.onCommand.addListener(e=>{e==="toggle_reader"&&O()})}async function O(){const e=await I();e&&s.send({tabId:e,event:"popup:content:toggleReader"})}function I(){return new Promise(e=>{chrome.tabs.query({active:!0,currentWindow:!0},async([t])=>{var a;return e(t!=null&&t.id&&((a=t.url)!=null&&a.startsWith("http"))?t.id:void 0)})})}async function U(){const e=[{id:2,condition:{initiatorDomains:[chrome.runtime.id],resourceTypes:[chrome.declarativeNetRequest.ResourceType.SUB_FRAME,chrome.declarativeNetRequest.ResourceType.XMLHTTPREQUEST]},action:{type:chrome.declarativeNetRequest.RuleActionType.MODIFY_HEADERS,requestHeaders:[{header:"Origin",operation:chrome.declarativeNetRequest.HeaderOperation.REMOVE}],responseHeaders:[{header:"X-Frame-Options",operation:chrome.declarativeNetRequest.HeaderOperation.REMOVE},{header:"Frame-Options",operation:chrome.declarativeNetRequest.HeaderOperation.REMOVE},{header:"Content-Security-Policy",operation:chrome.declarativeNetRequest.HeaderOperation.SET,value:"media-src 'none'; frame-src https://challenges.cloudflare.com https://www.google.com; font-src 'none'; object-src 'none';"}]}},{id:10,condition:{initiatorDomains:[chrome.runtime.id],requestDomains:["www.webtoons.com","m.webtoons.com"]},action:{type:chrome.declarativeNetRequest.RuleActionType.MODIFY_HEADERS,responseHeaders:[{header:"Content-Security-Policy",operation:chrome.declarativeNetRequest.HeaderOperation.SET,value:`script-src chrome-extension://${chrome.runtime.id}`}]}}];chrome.declarativeNetRequest.updateDynamicRules({removeRuleIds:(await chrome.declarativeNetRequest.getDynamicRules()).map(t=>t.id),addRules:e})}let v=!1;async function S(e){const t=chrome.runtime.getURL(e);(await chrome.runtime.getContexts({contextTypes:["OFFSCREEN_DOCUMENT"],documentUrls:[t]})).length>0||v||(v=!0,await chrome.offscreen.createDocument({url:chrome.runtime.getURL(e),reasons:[chrome.offscreen.Reason.DOM_SCRAPING,chrome.offscreen.Reason.BLOBS],justification:"Communicate with MangaPin web app, scrape manga websites, prepare manga cover images"}))}S("src/offscreen/index.html");N();u.setup();chrome.runtime.onInstalled.addListener(e=>{U(),e.reason===chrome.runtime.OnInstalledReason.INSTALL&&chrome.tabs.create({url:"https://mangapin.com/getting-started"})});s.addListeners([new r("main:openUrl",e=>{R(e.data,e.tabId)}),new r("content:main:getWebCommand",()=>{}),new r("bridge:main:ready",()=>{}),new r("main:openEntry",e=>{var a;const t=(a=e==null?void 0:e.data)==null?void 0:a.id;typeof t=="string"&&b(t)}),new r("main:addEntry",async e=>{await E(e.data)}),new r("main:setImgReferer",async e=>{chrome.declarativeNetRequest.updateSessionRules({addRules:[{id:e.data.id,condition:{initiatorDomains:[chrome.runtime.id],requestDomains:[e.data.url.split("//").slice(-1)[0].split("/")[0]],resourceTypes:[chrome.declarativeNetRequest.ResourceType.IMAGE]},action:{type:chrome.declarativeNetRequest.RuleActionType.MODIFY_HEADERS,requestHeaders:[{header:"Origin",operation:chrome.declarativeNetRequest.HeaderOperation.REMOVE},{header:"Referer",operation:chrome.declarativeNetRequest.HeaderOperation.SET,value:e.data.referer}]}}]})}),new r("main:cancelImgReferer",async e=>{chrome.declarativeNetRequest.updateSessionRules({removeRuleIds:[e.data.id]})})]);s.addListeners([new r("app:main:ping",()=>({version:"1.11.1",webAppOrigin:"https://my.mangapin.com"})),new r("app:main:notification",e=>{u.create(e.data)}),new r("app:main:hideNotification",e=>{u.hide(e.data)}),new r("app:main:clearNotifications",()=>{u.clear()}),new r("app:main:badge",e=>{const t=e.data.value;chrome.action.setBadgeBackgroundColor({color:"#000"}),chrome.action.setBadgeText(t?{text:t.toString()}:{text:""})}),new r("app:main:openUrl",e=>{R(e.data)})],{external:!0});