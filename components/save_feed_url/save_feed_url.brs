sub init()
    m.top.functionName = "saveurl"
end sub

' ****************************************

sub saveurl()
    reg = CreateObject("roRegistrySection",  "profile")
    reg.Write("primaryfeed", m.global.feedurl)
    reg.Flush()  
End sub