# -*- coding:utf-8 -*-
'''
GUIで使用されるリソースを動的に保持するモジュール

@author: shimarin
'''

def register(x, y):
    """
    GUIリソースを登録する。登録されたオブジェクトには gui.res.名称 でいつでもアクセスできるようになる。例えば gui.res.register("hoge", hoge) としてリソース登録された hogeオブジェクトには gui.res.hoge でアクセスできる。名前空間は単一なので衝突しないよう命名に注意すること。
    x: リソース名称
    y: 任意のオブジェクト
    """
    globals()[x] = y

def remove(x):
    """
    GUIリソースを削除する。
    x: リソース名称
    """
    del globals()[x]
