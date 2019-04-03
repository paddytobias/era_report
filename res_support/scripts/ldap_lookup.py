import sys
print sys.path
sys.path.append('/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages')

import ldap3
from pprint import pprint
import pandas as pd

ldap_uri = 'ldap://ldap.deakin.edu.au'
#SEARCH_BASE = 'ou=People,dc=deakin,dc=edu,dc=au'
search_base = 'ou=People,dc=deakin,dc=edu,dc=au'
attrs = ['*']


res_support = pd.read_csv("data/res_support_data.csv") # load data for names

contact_dict = {"name":[],"email":[], "deakinArea":[], "faculty":[], "institute":[]}

server = ldap3.Server(ldap_uri)

for i in range(len(res_support)):
	name = res_support.iloc[i,3]# extract user's name
	if pd.notnull(name):
                search_filter = "(cn="+name+")" # construct search query
        else:
                continue
	try:
                with ldap3.Connection(server, auto_bind=True) as conn: # estab connection and perform query
			conn.search(search_base, search_filter, attributes=attrs)
			pprint(conn.entries)
		query = conn.entries[0]
		email = query.mail # save the email from the user
		deakinArea = query.deakinArea # save deakinArea/school
		faculty = query.deakinFacultyDivision # save facilty
                institute = query.o  
		contact_dict["name"].append(name) # append to contacts
		contact_dict["email"].append(email)
		contact_dict["deakinArea"].append(deakinArea)
		contact_dict["faculty"].append(faculty)
		contact_dict["institute"].append(institute)
	
	except:
		"failed look up"

contact = pd.DataFrame(data=contact_dict)

contact.to_csv("data/ldap_lookup.csv") #output


