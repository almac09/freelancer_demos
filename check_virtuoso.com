import requests, json
from bs4 import BeautifulSoup

cookies = {
    'slc': 'BMH4g+FQ5OuKgO6zbNLCylSxIrjhW2f9S4f+hpTaNrXHjy/m1ZE5WHZNCRfAow0E',
    'CookiesEnabled': 'true',
    'CMSPreferredCulture': 'en-US',
    'ASP.NET_SessionId': '04awop2ejbv1v0ked5wpexir',
    'optimizelyEndUserId': 'oeu1440758719756r0.1534386717248708',
    '__CT_Data': 'gpv=1&apv_26555_www02=1',
    'WRUID': '0',
    'fuu': '1',
    'ATC': 'LastLoggedInAs=Anonymous&HasLoggedInBefore=0&SessionId=04awop2ejbv1v0ked5wpexir',
    'advisorsCatalogContent': 'open',
    '_gat': '1',
    'PRUM_EPISODES': 's=1440770348989&r=http',
}

headers = {
    'Origin': 'http://www.virtuoso.com',
    'Accept-Encoding': 'gzip, deflate',
    'Accept-Language': 'en-US,en;q=0.8,ca;q=0.6',
    'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36',
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'text/html, */*; q=0.01',
    'Referer': 'http://www.virtuoso.com/advisors',
    'X-Requested-With': 'XMLHttpRequest',
    'Connection': 'keep-alive',
}

payload = {"options": {"CurrentPage":1,
                       "FacetCategoryIndex":0,
                       "FacetCategoryTitle":"",
                       "FacetLimit":5,
                       "LeftToShow":0,
                       "ProductIds":[],
                       "RowsPerPage":1000,
                       "SearchMode":"Advisor",
                       "SearchTerms":"",
                       "SearchType":"Advisor",
                       "SearchView":"1col",
                       "SelectedFacets":[],
                       "SortType":"LeadGenDesc",
                       "StartRow":0}}
session = requests.Session()

resp = session.post('http://www.virtuoso.com/search/ajax/getsearchview', headers=headers, cookies=cookies, data=json.dumps(payload))

soup   = BeautifulSoup(resp.text)
agents = soup.find_all('a', attrs={'itemprop' : 'url'})
agents_slugs = [agent['href'] for agent in agents]

for slug in agents_slugs:
    url = 'http://www.virtuoso.com' + slug
    resp = session.get(url)
    soup   = BeautifulSoup(resp.text)
    about_me = soup.find('div', attrs={'id' : 'MyBackgroundView'})
    # -1 means that the email does not exist!!    
    if about_me:
        print about_me.text.find('@')
    else:
        print -1
