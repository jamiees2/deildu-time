###
Module dependencies
###
request = require("request")
cheerio = require('cheerio')
iconv = require('iconv-lite')
peerflix = require('peerflix')
address = require('network-address')
hat = require('hat')
proc = require('child_process')
querystring = require('querystring');

# secrets = require("../secrets")
# console.log secrets
credentials = null

API_HOST = "http://deildu.net"
LOGIN_KEY = '<form name="loginform" id="loginform" action="takelogin.php" method="POST">'

jar = request.jar()

loggedIn = false
if window.localStorage["deildu.cookies"]?
    cookies = JSON.parse(window.localStorage["deildu.cookies"])
    cookies.forEach (cookie) ->
        jar.setCookie(cookie,API_HOST)
    loggedIn = true
request = request.defaults
    jar: jar
    encoding: null
    headers:
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2049.0 Safari/537.36'

exports.login = (creds,callback) ->
    if typeof creds is "function"
        return if credentials is null
        callback = creds
        creds = credentials
    credentials = creds
    return callback(null) if loggedIn
    console.log credentials
    return callback("Username or password incorrect") unless credentials.username? and credentials.password?
    formData = querystring.stringify(credentials)
    len = formData.length
    request({
        headers: {
            'Content-Length': len,
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        uri: "#{API_HOST}/takelogin.php",
        body: formData,
        method: 'POST',
        encoding: null
    }, (loginErr, loginResponse, body) ->
        if loginErr
            console.log loginErr
            return
        body = toUtf8 body
        return callback("Username or password incorrect") if body.indexOf("Username or password incorrect.") >= 0
        jar._jar.getSetCookieStrings API_HOST,{allPaths: true}, (err, cookies) ->
            console.log cookies
            window.localStorage["deildu.cookies"] = JSON.stringify(cookies)
        loggedIn = true
        callback(null)
    )
    # r = request.post("#{API_HOST}/takelogin.php", {headers: {'Content-Length': len}}, 

toUtf8 = (body) ->
    # body
    return iconv.decode(body,'iso-8859-1')

parseBrowse = (body) ->
    $ = cheerio.load(body)
    data = []
    $('.torrentlist tr:not(:first-child)').each ->
        $this = $(@)
        $td = $this.find('td')
        if $td.length > 1

            td = []
            $td.each ->
                td.push($(this))
            obj = 
                id: td[1].find('a').attr('href').substr('details.php?id='.length)
                category: td[0].find('a img').attr('alt')#.substr('/pic/2/'.length).slice(0,-4).replace(/[0-9]/g,'')
                name: td[1].text().trim()
                file_count: td[3].text().trim()
                # ignore comments
                date: td[5].html().replace(/\<br\>|\s/g," ").trim()
                size: td[6].text().trim()
                # ignore users downloaded
                seeders: td[8].text().trim()
                leechers: td[9].text().trim()
                user: td[10].text().trim()
            obj.torrent = td[2].find('a').attr('href')
            obj.torrent = obj.torrent.substr(obj.torrent.lastIndexOf('/') + 1)

            data.push(obj)
    return data

# exports.login secrets.deildu, -> # Attempt login immediately
    

exports.browse = (opts,callback) ->
    args = arguments
    unless loggedIn
        return setTimeout ->
            exports.browse.apply(this,args)
        , 500

    if typeof opts is "function"
        callback = opts 
        opts = null
    url = "#{API_HOST}/browse.php"
    if opts
        url += "?" + querystring.stringify opts
    request.get url, (err, httpResponse, body) ->
        if err
            return callback err
        body = toUtf8(body)
        data = parseBrowse(body)
        unless data.length > 0
            if body.indexOf(LOGIN_KEY) isnt -1
                loggedIn = false
                return exports.login ->
                    exports.browse.apply(this,args)
        callback(null,data)

exports.details = (id, callback) ->
    args = arguments
    unless loggedIn
        return setTimeout ->
            exports.details.apply(this,args)
        , 500
    request.get "#{API_HOST}/details.php?id=#{id}", (err, httpResponse, body) ->
        if err
            return callback err

        body = toUtf8(body)
        $ = cheerio.load(body)
        $td = $('#columns table:first-of-type tr td:not(.rowhead):not(.heading)')
        unless $td.length > 0
            if body.indexOf(LOGIN_KEY) isnt -1
                loggedIn = false
                return exports.login ->
                    exports.details.apply(this,args)
        td = []
        $td.each ->
            td.push($(this))
        obj = 
            title: $('#columns h1').text()
            torrent: td[0].text().trim()
            info_hash: td[1].text().trim()
            description: td[2].html()
            type: td[3].text().trim()
            last_seeder: td[4].text().trim()
            size: td[5].text().trim()
            added: td[6].text().trim()
            # ignore views
            # ignore hits
            # ignore snatched
            user: td[10].text().trim()
            file_count: parseInt(td[11].text().trim())
        sharers = td[12].text().trim().split('=')[0].split(',')
        obj.seeders = parseInt(sharers[0])
        obj.leechers = parseInt(sharers[1])
        callback null, obj


exports.torrent = (id, torrent, callback) ->
    args = arguments
    unless loggedIn
        return setTimeout ->
            exports.browse.apply(this,args)
        , 500
    request.get "#{API_HOST}/download.php/#{id}/#{torrent}", (err, httpResponse, body) ->
        if err
            return callback(err)
        if toUtf8(body).indexOf(LOGIN_KEY) isnt -1
            loggedIn = false
            return exports.login ->
                exports.torrent.apply(this,args)
        callback(null, body)

