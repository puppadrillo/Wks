object WebModule1: TWebModule1
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <
    item
      Name = 'DefaultHandler'
      PathInfo = '/Default'
      OnAction = WebModule1DefaultHandlerAction
    end
    item
      Name = 'InitWebAction'
      PathInfo = '/Init'
      OnAction = WebModule1InitWebActionAction
    end
    item
      Name = 'InfoWebAction'
      PathInfo = '/Info'
      OnAction = WebModule1InfoWebActionAction
    end
    item
      Name = 'LoginWebAction'
      PathInfo = '/Login'
      OnAction = WebModule1LoginWebActionAction
    end
    item
      Name = 'LoginTryWebAction'
      PathInfo = '/LoginTry'
      OnAction = WebModule1LoginTryWebActionAction
    end
    item
      Name = 'LogoutWebAction'
      PathInfo = '/Logout'
      OnAction = WebModule1LogoutWebActionAction
    end
    item
      Name = 'AccountWebAction'
      PathInfo = '/Account'
      OnAction = WebModule1AccountWebActionAction
    end
    item
      Name = 'AccountCreateWebAction'
      PathInfo = '/AccountCreate'
      OnAction = WebModule1AccountCreateWebActionAction
    end
    item
      Name = 'AccountCreateTryWebAction'
      PathInfo = '/AccountCreateTry'
      OnAction = WebModule1AccountCreateTryWebActionAction
    end
    item
      Name = 'AccountCreateDoneWebAction'
      PathInfo = '/AccountCreateDone'
      OnAction = WebModule1AccountCreateDoneWebActionAction
    end
    item
      Name = 'AccountRecoverWebAction'
      PathInfo = '/AccountRecover'
      OnAction = WebModule1AccountRecoverWebActionAction
    end
    item
      Name = 'AccountRecoverTryWebAction'
      PathInfo = '/AccountRecoverTry'
      OnAction = WebModule1AccountRecoverTryWebActionAction
    end
    item
      Name = 'AccountRecoverDoneWebAction'
      PathInfo = '/AccountRecoverDone'
      OnAction = WebModule1AccountRecoverDoneWebActionAction
    end
    item
      Name = 'TestWebAction'
      PathInfo = '/Test'
      OnAction = WebModule1TestWebActionAction
    end
    item
      Default = True
      Name = 'PageWebAction'
      PathInfo = '/Page'
      OnAction = WebModule1PageWebActionAction
    end
    item
      Name = 'NewsWebAction'
      PathInfo = '/News'
      OnAction = WebModule1NewsWebActionAction
    end
    item
      Name = 'SocialWebAction'
      PathInfo = '/Social'
      OnAction = WebModule1SocialWebActionAction
    end
    item
      Name = 'MessageWebAction'
      PathInfo = '/Message'
      OnAction = WebModule1MessageWebActionAction
    end
    item
      Name = 'NotificationWebAction'
      PathInfo = '/Notification'
      OnAction = WebModule1NotificationWebActionAction
    end
    item
      Name = 'DashboardWebAction'
      PathInfo = '/Dashboard'
      OnAction = WebModule1DashboardWebActionAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  AfterDispatch = WebModuleAfterDispatch
  OnException = WebModuleException
  Height = 230
  Width = 415
end
