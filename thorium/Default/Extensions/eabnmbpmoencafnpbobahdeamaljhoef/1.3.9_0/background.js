async function callTranslateWithText(e,t,n,o,r,a){const i=new Headers;i.append("Authorization",`Bearer ${r}`),i.append("Content-Type","application/json");try{const r=await fetch("https://chrome-extension-translation.wn.r.appspot.com/lang/"+t+"/translate-text?api="+o+"&source_lang="+t+"&target_lang="+n+("on"===a?"&pronunciation=true":""),{method:"POST",headers:i,body:JSON.stringify({text:e})}).then((e=>e.json()));return r.error?{error:`Translation: ${r.error}`}:r.translation?{translation:r.translation,pronunciation:r.pronunciation}:{error:`Error: translation is not valid: ${r}`}}catch(e){return{error:`Translation: ${e.message}`}}}function pingContentScript(e,t){chrome.tabs.sendMessage(e.id,{message:t},(e=>{e&&clearTimeout(n)}));var n=setTimeout((()=>{chrome.scripting.insertCSS({files:["css/content.css"],target:{tabId:e.id}}),chrome.scripting.executeScript({files:["content.js"],target:{tabId:e.id}}),setTimeout((()=>{chrome.tabs.sendMessage(e.id,{message:t})}),100)}),100)}chrome.storage.sync.get((e=>{e.api||chrome.storage.sync.set({api:"gpt"}),e.capture_mode||chrome.storage.sync.set({capture_mode:"single"}),e.pronunciation||chrome.storage.sync.set({pronunciation:"off"}),e.source_lang||chrome.storage.sync.set({source_lang:"Japanese"}),e.target_lang||chrome.storage.sync.set({target_lang:"English"}),e.api_calls_location||chrome.storage.sync.set({api_calls_location:"Backend"}),void 0===e.icon&&(e.icon=!1,chrome.storage.sync.set({icon:!1})),chrome.action.setIcon({path:[16,19,38,48,128].reduce(((e,t)=>(color="rice",e[t]=`/icons/${color}/${t}x${t}.png`,e)),{})})})),chrome.action.onClicked.addListener((e=>{chrome.storage.sync.get((t=>{t.idToken?"screen"===t.capture_mode?pingContentScript(e,"screenCapture"):pingContentScript(e,"initCrop"):chrome.runtime.openOptionsPage()}))})),chrome.commands.onCommand.addListener((e=>{"take-screenshot"===e&&chrome.tabs.query({active:!0,currentWindow:!0},(e=>{chrome.storage.sync.get((t=>{"screen"===t.capture_mode?pingContentScript(e[0],"screenCapture"):pingContentScript(e[0],"initCrop")}))}))})),chrome.runtime.onMessage.addListener(((e,t,n)=>("capture"===e.message?chrome.tabs.query({active:!0,currentWindow:!0},(e=>{chrome.tabs.captureVisibleTab(e[0].windowId,(e=>{n({message:"image",image:e})}))})):"active"===e.message?e.active?chrome.storage.sync.get((()=>{chrome.action.setTitle({tabId:t.tab.id,title:"Crop"}),chrome.action.setBadgeText({tabId:t.tab.id,text:"◩"})})):(chrome.action.setTitle({tabId:t.tab.id,title:"Crop Initialized"}),chrome.action.setBadgeText({tabId:t.tab.id,text:""})):"logout"===e.message&&(chrome.runtime.openOptionsPage(),setTimeout((()=>{chrome.runtime.sendMessage({message:"logout"})}),500)),!0))),chrome.runtime.onInstalled.addListener((()=>{chrome.contextMenus.create({id:"translate-menu",title:"Translate %s",contexts:["selection"]})})),chrome.contextMenus.onClicked.addListener(((e,t)=>{"translate-menu"===e.menuItemId&&(pingContentScript(t,"initTextTranslation"),chrome.storage.sync.get((n=>{n.idToken?callTranslateWithText(e.selectionText,n.source_lang,n.target_lang,n.api,n.idToken,n.pronunciation).then((e=>{e.error?pingContentScript(t,{error:`Translation: ${e.error}`,pronunciation:void 0}):pingContentScript(t,e)})).catch((e=>{console.error(`error: ${e.message}`),pingContentScript(t,{error:`Translation: ${e.message}`,pronunciation:void 0})})):pingContentScript(t,{translation:"Please login first. Right click on the extension icon and click on options.",pronunciation:void 0})})))}));