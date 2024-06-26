import { LoginApI, ResManager, TokenStore } from '@orderHome/common/basic';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';
import { Log } from '@abner/log';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  /*-----------------------👇👇 function 👇👇--------------------------------*/
  // 登录方法
  login() {
    // 创建授权请求，并设置参数
    let authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // 获取手机号需要传如下scope，传参数之前需要先申请对应scope权限,才能返回对应数据
    authRequest.scopes = ['phone'];
    // 获取code需传如下permission
    authRequest.permissions = ['serviceauthcode'];
    // 用户是否需要登录授权，该值为true且用户未登录或未授权时，会拉起用户登录或授权页面
    authRequest.forceAuthorization = true;
    // 用于防跨站点请求伪造，非空字符串即可
    authRequest.state = util.generateRandomUUID();
    // 执行请求
    try {
      let controller = new authentication.AuthenticationController(getContext(this));
      controller.executeRequest(authRequest, async (err, data) => {
        if (err) {

          Log.error('auth fail,error: %{public}s' + JSON.stringify(err));
          return;
        }
        let authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
        let state = authorizationWithHuaweiIDResponse.state;
        if (state != undefined && authRequest.state != state) {
          Log.error('auth fail,The state is different: %{public}s' +
          JSON.stringify(authorizationWithHuaweiIDResponse));
          return;
        }
        Log.debug('auth success: %{public}s' +
        JSON.stringify(authorizationWithHuaweiIDResponse));
        let authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
        let code = authorizationWithHuaweiIDCredential.authorizationCode;
        // 开发者处理code=> 获取一键登录的授权 code=>调用后台 api =》获取 token
        Log.warn(`华为授权码：${code}`)
        promptAction.showDialog({ message: `华为授权码：${code}` })
        /*测试用*/
        const token = await LoginApI({
          code: code!,
          clientId: '111293791',
          clientSecret: 'f41254cd94d3a104f53c744aa46a3b80ff37307968348e7fa94325bb40a6e043'
        })
        Log.info('token👼' + token)
        // 持久化
        await TokenStore.setToken(token)
        router.replaceUrl({
          url: 'pages/Index'
        })
      });
    } catch (error) {
      Log.error('auth failed: %{public}s' + JSON.stringify(error));
    }
  }

  // 测试用
  async testLogin() {
    const token =
      'eyJhbGciOiJIUzI1NiJ9.eyJjdXJyZW50VXNlciI6IntcInVzZXJuYW1lXCI6XCIzNTQyMzQ4NEBxcS5jb21cIixcInBhc3N3b3JkXCI6XCJcIixcIm5pY2tOYW1lXCI6XCLmiqTnkIblkZgxXCIsXCJlbWFpbFwiOlwiMzU0MjM0ODRAcXEuY29tXCIsXCJyZWFsTmFtZVwiOlwi5oqk55CG5ZGYMVwiLFwibW9iaWxlXCI6XCIxODIxMTAyMTg5NlwiLFwic2V4XCI6XCIwXCIsXCJkZXB0Tm9cIjpcIjEwMDAwMTAwNTAwMDAwMFwiLFwicG9zdE5vXCI6XCIxMDAwMDEwMDUwMDMwMDBcIixcImRhdGFTdGF0ZVwiOlwiMFwiLFwiYXZhdGFyXCI6XCJodHRwczovL3lqeS1vc3MtdmlkZW9zLm9zcy1hY2NlbGVyYXRlLmFsaXl1bmNzLmNvbS9ncnp4aHouanBnXCIsXCJpZFwiOjE2NzE0MDMyNTY1MTkwNzgyNzUsXCJjcmVhdGVUaW1lXCI6MTcxNTU2ODM5MDAwMCxcInVwZGF0ZVRpbWVcIjoxNzE1NTY4MzkwMDAwLFwiY3JlYXRlQnlcIjoxNjcxNDAzMjU2NTE5MDc4MTM4fSIsImV4cCI6MTQ2NzU2NTk0Nzd9.8PrMKBNrVVCfcI4DgICxp6oBQGqy46m3oglFQCiKtzw'
    // 持久化
    await TokenStore.setToken(token)
    router.replaceUrl({
      url: 'pages/Index'
    })
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        // app 信息
        Column() {
          Text() {
            Span('标题啊标题啊')
              .fontColor('#000')
              .fontSize(24)
              .fontWeight(700)
          }

          Text() {
            Span('登录页')
              .fontColor('#000')
              .fontSize(24)
              .fontWeight(700)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#fff')

        Button({ stateEffect: true }) {
          Row({ space: 6.5 }) {
            Image(ResManager.IC_HUAWEI)
              .width(24)
              .aspectRatio(1)
            Text('华为登录')
              .fontColor('#fff')
              .fontWeight(500)
              .fontSize(ResManager.EC_MODULE_TITLE_FS)
          }
        }
        .margin({ top: 150 })
        .width(250)
        .height(40)
        .backgroundColor(ResManager.EC_MAIN_COLOR)
        .onClick(() => {
          this.testLogin()
        })

      }
    }
    .width('100%')
    .height('100%')
  }
}