(function(){"use strict";async function p({addListener:t,removeListener:o,transform:n,filter:i,handler:r,onTimeout:e,timeout:a,once:s}){return new Promise(c=>{t(y);const l=()=>s===!0&&o(y),f=a?setTimeout(()=>{l(),c(void 0),e?.()},a):void 0;async function y(d,...w){d=n?n(d):d,d!==void 0&&(!i||i(d,...w))&&(l(),c(d),r?.(d,...w),f&&clearTimeout(f))}})}async function g(t){return(await p({addListener:o=>window.addEventListener("message",o),removeListener:o=>window.removeEventListener("message",o),...t}))?.data}function h({event:t,filter:o,handler:n,senderWindow:i,targetOrigin:r}){g({filter:e=>e.data?.event===t&&!!e.data?.reqId&&(!o||o(e)),handler:async e=>{const a=await n?.(e);(i||window).postMessage({resId:e.data.reqId,result:a},r??"*")}})}async function u(t,o,n){const i=await n(()=>{t=0});if(i!==void 0)return i;if(!(t<=0))return await new Promise(r=>{setTimeout(async()=>{const e=await u(t-1,o,n);r(e)},o)})}function m(){const t={delay:{loading:!0}};let o=location.pathname,n={...t};async function i(r,e){if(!e.headers.get("Content-Type")?.includes("application/json")){delete n[r];return}n[r]={res:e.clone()}}window.fetch=new Proxy(window.fetch,{apply:async(r,e,a)=>{o!==location.pathname&&(o=location.pathname,n={...t});const[s,c]=a;return c?.method&&c.method.toLowerCase?.()!=="get"?await r.apply(e,a):(n[s]={loading:!0},delete n.delay,await r.apply(e,[s,c]).then(l=>(i(s,l),l)).catch(l=>{throw delete n[s],l}))}}),h({event:"tk:fetchResult",async handler(r){if(r.origin!==location.origin)return;const{baseUrl:e,segments:a}=r.data.args||{};return!Array.isArray(a)||typeof e!="string"?void 0:await T(()=>n,e,a.filter(s=>typeof s=="string"||typeof s?.isAny=="boolean"))}})}function v(t,o,n){const i=Object.keys(t).find(r=>L(r,o,n));return i?{url:i,result:t[i]}:void 0}function L(t,o,n){const i=t.replace(location.origin,""),r=o.replace(location.origin,"");if(!i.startsWith(r))return!1;const e=i.replace(r,"").split("?")[0].split("#")[0].split("/").filter(Boolean);return e.length===n.length&&n.every((a,s)=>a?.isAny||a===e[s])}function T(t,o,n){let i=15;return u(150,100,async r=>{const e=v(t(),o,n);if(!e){const s=Object.values(t());!(!s.length||s.some(c=>c.loading))&&!--i&&r();return}const a=await b(e.result);return a?{url:e.url,value:a}:void 0})}async function b(t){const{res:o,parsed:n,loading:i}=t;if(!i)return t.parsed=n??await o?.json().catch(async()=>JSON.parse(await o.text())).catch(()=>{}),delete t.res,t.parsed}m()})();