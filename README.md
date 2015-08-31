Gimbal-Proximity-iOS-SampleApp
=================================================

Gimbal Proximity Reference Application that starts the service without using the OAuth flow.  

This reference application is setup with some default Application-Id and Application-Secret values that will most likely not work for everyone. 

To create your own Id/Secret values follow the Gimbal-iOS-Proximity-Quickstart guide and replace the Application-Id and Application-Secret in the ApplicationContext.m file as below:


    [FYX setAppId:@"your-application-id"
         appSecret:@"your-application-secret"
         callbackUrl:@"your-callback-url"];

As long as you have beacons associated to your developer account and they are within range of your device, you will see their information displayed when you run the application.
