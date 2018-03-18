sub init()
	m.top.functionName = "getContent"
end sub

' **********************************************

sub getContent()
	feedurl = m.global.feedurl

	m.port = CreateObject ("roMessagePort")
	searchRequest = CreateObject("roUrlTransfer")
	searchRequest.setURL(feedurl)
	searchRequest.EnableEncodings(true)
	httpsReg = CreateObject("roRegex", "^https:", "")
	if httpsReg.isMatch(feedurl)
		searchRequest.SetCertificatesFile ("common:/certs/ca-bundle.crt")
		searchRequest.AddHeader ("X-Roku-Reserved-Dev-Id", "")
		searchRequest.InitClientCertificates ()
	end if


	text = searchRequest.getToString()

	reHasGroups = CreateObject("roRegex", "group-title\=" + chr(34) + "?([^" + chr(34) + "]*)"+chr(34)+"?,","")
	hasGroups = reHasGroups.isMatch(text)
	print hasGroups

	reLineSplit = CreateObject ("roRegex", "(?>\r\n|[\r\n])", "")
	reExtinf = CreateObject ("roRegex", "(?i)^#EXTINF:\s*(\d+|-1|-0).*,\s*(.*)$", "")

	rePath = CreateObject ("roRegex", "^([^#].*)$", "")
	inExtinf = false
	con = CreateObject("roSGNode", "ContentNode")
	if not hasGroups
		group = con
	else
		groups = []
	end if

	REM #EXTINF:-1 tvg-logo="" group-title="uk",BBC ONE HD
	for each line in reLineSplit.Split (text)
		if inExtinf
			maPath = rePath.Match (line)
			if maPath.Count () = 2
				item = group.CreateChild("ContentNode")
				item.url = maPath [1]
				item.title = title

				inExtinf = False
			end if
		end if
		maExtinf = reExtinf.Match (line)
		if maExtinf.Count () = 3
			if hasGroups
				groupName = reHasGroups.Match(line)[1]
				group = invalid
				REM Don't know why, but FindNode refused to work here
				for x = 0 to con.getChildCount()-1
					node = con.getChild(x)
					if node.id = groupName
						group = node
						exit for
					end if
				end for
				if group = invalid
					group = con.CreateChild("ContentNode")
					group.contenttype = "SECTION"
					group.title = groupName
					group.id = groupName
				end if
			end if
			length = maExtinf[1].ToInt ()
			if length < 0 then length = 0
			title = maExtinf[2]
			inExtinf = True
		end if
	end for

	m.top.content = con
end sub
