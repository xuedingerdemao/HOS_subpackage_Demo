import { preferences } from '@kit.ArkData'
import { ADV_KEY, ADV_STORE } from '../../constants'
import { AdvertClass } from '../../models/index'

// 默认广告
const defaultAd: AdvertClass = {
  showAd: true,
  adTime: 5,
  adImg: $r('app.media.003')
}

// 读写广告配置的class
class AdvSettingStore{
  // 此时需要上下文和读写方法
  context: Context

  constructor(cxt: Context) {
    this.context = cxt
  }

  // 初始化首选项仓库
  initAdvStore() {
    return preferences.getPreferencesSync(this.context, {
      name: ADV_STORE
    })
  }

  // 设置广告首选项·
  async setAdvStore(adv: AdvertClass) {
    const store = this.initAdvStore()
    store.putSync(ADV_KEY, JSON.stringify(adv))
    // 写入磁盘
    await store.flush()
  }

  // 取广告首选项
  getAdvStore() {
    const store = this.initAdvStore()
    return JSON.parse(store.getSync(ADV_KEY, JSON.stringify(defaultAd)) as string) as AdvertClass
  }
}

export { defaultAd, AdvSettingStore }