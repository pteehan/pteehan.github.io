# -*- coding: utf-8 -*-


import pandas as pd
import numpy as np

import product_similarity


def test_init_similarity_table():
    # should make an nxn array of all zeros
    test_table = product_similarity.SimilarityTable(['p1', 'p2', 'p3'])
    assert test_table.products == ['p1', 'p2', 'p3']
    assert np.array_equal(test_table.table,np.zeros((3,3)))
    
    
def test_add_products():
    test_table = product_similarity.SimilarityTable(['p1', 'p2', 'p3'])
    
#    # [1,1], [1,2], [2,1], and [2,2] should all get incremented
    test_table.add_product_set(['p1', 'p2'])
    assert np.array_equal(test_table.table, np.array(([1,1,0], [1,1,0], [0,0,0])))
    
    # [2,2], [2,3], [3,2], and [3,3] should all get incremented
    test_table.add_product_set(['p2', 'p3'])
    assert np.array_equal(test_table.table, np.array(([1,1,0], [1,2,1], [0,1,1])))

#    # everything should get incremented
    test_table.add_product_set(['p1', 'p2', 'p3'])
    assert np.array_equal(test_table.table, np.array(([2,2,1], [2,3,2], [1,2,2])))


def make_test_table():
    search_results = pd.DataFrame({'session': [1,1,1,2,2,3,3], 
                                   'product': ['a', 'b', 'c', 'b', 'c', 'b', 'c']})
    return product_similarity.get_similarity_table(search_results)
    
def test_get_similarity_table():
    test_table = make_test_table()
    assert np.array_equal(test_table.table, np.array(([1,1,1], [1,3,3], [1,3,3])))
    

def test_export_product(): 
    test_table = make_test_table()
    out = test_table._export_product('a')
    assert out['product'].tolist() == ['b', 'c']
    assert out['rank'].tolist() == [1,1]
    assert out['appearances'].tolist() == [1,1]
    
    out = test_table._export_product('b')
    assert out['product'].tolist() == ['c', 'a']
    assert out['rank'].tolist() == [1,2]
    assert out['appearances'].tolist() == [3,1]

def test_as_data_frame():
    test_table = make_test_table()
    out = test_table.as_data_frame()
    assert out['reference_product'].tolist() == ['a', 'a', 'b', 'b', 'c', 'c']
    
    out = test_table.as_data_frame(['a','c'])
    assert out['reference_product'].tolist() == ['a', 'a', 'c', 'c']

    