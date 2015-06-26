import urllib

def run(options, args):
    url = 'http://github-preview.herokuapp.com/render'
    data = None
    with open(args[0]) as f:
        data = f.read()
    params = urllib.urlencode({'format':'markdown', 'data':data})
    f = urllib.urlopen(url, params)
    print "<html>"
    print "<head>"
    print '<link href="http://github-preview.herokuapp.com/stylesheets/github.css" rel="stylesheet" type="text/css" />'
    print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset= UTF-8\">"
    print "</head>"
    print "<body><div class='panel wikistyle' id='preview' style='margin: 1px 0 0 10px; padding: 0 10px 0 10px; overflow: auto;'>"
    print f.read()
    print "</div></body>"
    print "</html>"
