import {createApp} from 'vue'
import './style.css'
import App from './App.vue'
import router from './router/index.ts'


import * as ElementPlusIconsVue from '@element-plus/icons-vue'

import zhCn from 'element-plus/es/locale/lang/zh-cn'

const app = createApp(App)
import ElementPlus from 'element-plus'

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}


import ECharts from 'vue-echarts'
import 'element-plus/dist/index.css'
import 'element-plus/theme-chalk/display.css'
import { createPinia } from 'pinia'
import { createPersistedState } from 'pinia-plugin-persistedstate'

app.component('v-chart', ECharts)
app.use(ElementPlus, { locale: zhCn })
app.use(createPinia().use(createPersistedState()))
app.use(router)
app.mount('#app')

