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
product (int)    - ID of product viewed by user (can repeat in session) """

import pandas as pd
import numpy as np
import ranking as rank
import pickle
import os
os.chdir("/Users/paul.teehan/pteehan.github.io/code/hams/")


# Paul Teehan
# June 7, 2016
# paul.teehan@gmail.com


"""
Task 3 (HOMEWORK): For every product, that got displayed,
                   find three products that are most often displayed together
                   in the same session.                                
"""


class SimilarityTable(object):
    """ A matrix representation of product similarity, which is based on 
    the number of times products appear in sets together
    """
    def __init__(self, all_products):
        """ Set up a zero matrix of size nxn where n is number of products """
        self.n = len(all_products)
        self.table = np.zeros((self.n,self.n))
        self.products = all_products
    
    def add_product_set(self, products):
        """ Increment the count for each product pair in an input set """
        # element i,j records how many times product j appears in a search with product i
        # the diagonal (i=j) is the number of times i appeared in search
        for product_i in products:
            print (product_i)
            for product_j in products:
                self.table[self.products.index(product_i), self.products.index(product_j)] += 1
     
    def as_data_frame(self, products=[], max_rank=10):
        """ Produce a data frame representation of similarity for a set of products"""
        if len(products)==0:
            products = self.products  # default to whole set
        # row-wise concatenate the data frame export for each product                      
        out = self._export_product(products[0], max_rank=max_rank)
        for i in products[1:len(products)]:
            print(i)
            out = pd.concat((out, self._export_product(i,max_rank=max_rank)))
        return out               
                
    def _export_product(self, product, max_rank=10):
        """ Produce a data frame representation of products that are similar to a reference product """
        
        row = self.table[self.products.index(product),]
        out = pd.DataFrame({'reference_product':product,
                            'product':self.products,
                            'appearances': row})
                            
        # scale the number of appearances relative to the total number of chances for it to appear                    
        out['opportunities'] = out[out['reference_product']==out['product']]['appearances'].values[0]
        out['appearances_pct'] = out['appearances']/out['opportunities']

        # eliminate the reference product and any products that don't appear
        out = out[out['reference_product']!=out['product']]
        out = out[out['appearances'] > 0]
        
        # rank the products.  rank.Ranking will allow ties, i.e. 1,2,3,3,3,3,3
        out.sort_values('appearances_pct', ascending=False, inplace=True)         
        out['rank'] = [i[0] for i in list(rank.Ranking(out['appearances_pct'], start=1))]        
        
        # filter so only the top 'n' products remain (including ties)      
        out = out[out['rank'] <= max_rank]
        return out


def get_sessions():
    """ merges session and product listings for displayed search results and viewed products """ 
    search_results = pd.read_csv('displayed_search_results.csv')[['session', 'product']]
    viewed_products = pd.read_csv('viewed_products.csv')  
    return pd.concat((search_results, viewed_products))

    
def get_similarity_table(sessions_products):
    """ Creates and populates a similarity table based on common membership in sessions """
    all_products = sessions_products['product'].unique().tolist()
    all_products.sort()
    table = SimilarityTable(all_products) # initialize nxn matrix with all zeros
    
    sessions = sessions_products['session'].unique().tolist()        
    for session in sessions:
        # increment counts for each pair of products in the session
        this_session = sessions_products[sessions_products['session']==session]
        product_set = this_session['product'].unique().tolist()
        table.add_product_set(product_set) 
    
    return table
    

def do_analysis():
    max_rank=3
    sessions_products = get_sessions()
    table = get_similarity_table(sessions_products)    
    # save table so we can load it for analysis later
    pickle.dump(table, open('similarity_table.p', 'wb'))
    
    # we are asked to find similar products for everything that is in viewed_products.csv
    viewed_products = pd.read_csv('viewed_products.csv')['product'].unique().tolist()
    out = table.as_data_frame(products=viewed_products,max_rank=max_rank)
    out.to_csv('task3_output.csv')
    return out


if __name__ == "__main__":
    do_analysis()

