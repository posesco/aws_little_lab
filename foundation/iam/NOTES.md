* Create a user group (developers, accountants) >> I can attach a policy as permission. 
* Create a new user >> I can attach a policy as permission. (predifined policies S3, EC2, lambda)
    jesus.posada.develop
    Feel-Duly-Irritably5-Awkward
    jesus.posada.accountant
    Duly-AwkwardDuly-Irritably48@

* Attach policies
* Create a role : El servicio tiene permiso de usar lo que digan las politicas
    Service: EC2
    Policies: S3, CloudWatch 






ManagedBy  Console
Env        dev
Owner      posesco
Component  identities


Para credenciales en pipeline:
https://github.com/aws-actions/configure-aws-credentials
Identity providers
OpenID Connect
https://token.actions.githubusercontent.com
sts.amazonaws.com