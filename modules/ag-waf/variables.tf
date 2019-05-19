

# CUSTOM VARIABLES - TUNNING WAF #
#   BE CAREFUL, MASSIVE IMPACT   #

#default = "50"
variable "ErrorThreshold" {
    default = "500"
}
#default = "400"
variable "RequestThreshold" {
    default = "800"
}
variable "WAFBlockPeriod" {
    default = "240"
}


# TURN ON COMPONENTS #
# ***   DO NOT TOUCH  ***  #

variable "ActivateBadBotProtectionParam" {
    default = "yes"
}
variable "ActivateHttpFloodProtectionParam" {
    default = "yes"
}
variable "ActivateReputationListsProtectionParam" {
    default = "yes"
}
variable "ActivateScansProbesProtectionParam" {
    default = "yes"
}
variable "CrossSiteScriptingProtectionParam" {
    default = "yes"
}
variable "SqlInjectionProtectionParam" {
    default = "yes"
}


# IMPROVE AWS WAF #
# Helps Amazon tune WAF functionality - highly recommended
variable "SendAnonymousUsageData" {
    default = "no"
}
