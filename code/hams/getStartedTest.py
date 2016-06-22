# -*- coding: utf-8 -*-
"""
This is practical test for the data analyst position at HaenselAMS.

You have two CSV files.

displayed_search_results.csv,
which contasins following columns (named in header on the first line):
session (string) - a unique identifier of a user session on a website,
search (int)     - identifier of a search (unique within session),
position (int)   - position of search result
product (int)    - ID of a product (same product can be on multiple positions)

viewed_products.csv,
which contains only two columns (named in header on the first line):
session (string) - a unique ID of user sesseion (same as before),
product (int)    - ID of product viewed by user (can repeat in session)
"""

import pandas as pd
import numpy as np
import os
os.chdir("/Users/paul.teehan/pteehan.github.io/code/hams/")

search_results = pd.read_csv('displayed_search_results.csv')
viewed_products = pd.read_csv('viewed_products.csv')



        
def add_products(table, products):
    """ Given a list of products that appeared together in a search, increments their 
    view counts in the table """
    for product_i in products:
        for product_j in products[products!=product_i]:
            table[table['product_i'==product_i and 'product_j'==product_j]]['count'] += 1
            table[table['product_j'==product_i and 'product_i'==product_j]]['count'] += 1
    
  
def get_similarity_table(search_results):
    all_products = search_results['product'].unique().tolist()
    all_products.sort()
    n_products = len(all_products)
    similarity_table = pd.DataFrame([(x, y) for x in all_products for y in all_products])
    similarity_table.columns = ['product_i', 'product_j']
    similarity_table['count'] = 0
    
    sessions = search_results['session'].unique().tolist()
        
    for session in sessions:
        this_session = search_results[search_results['session'==session]]
        this_products = this_session['product'].unique().tolist()
        add_products(similarity_table, this_products)
    
    #for each unique session:
    # get list of products
    # for each product
    # increment count 
    
    return similarity_matrix

get_distance_matrix(search_results[0:5])



"""


Task 1: Find ten products that appear most often
        on one of the top five positions in search.
"""



"""
Task 2: Calculate what is the chance that a product that is displayed
        on first place in search gets viewed in the same session.
        What is the chance of product of shown on 10th place is viewed?
"""

"""
Task 3 (HOMEWORK): For every product, that got displayed,
                   find three products that are most often displayed together
                   in the same session.
"""