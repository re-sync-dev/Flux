"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[775],{28404:e=>{e.exports=JSON.parse('{"functions":[{"name":"Length","desc":"Returns the true length of a table instead of differing between array and dictionary tables.","params":[{"name":"TableToCheck","desc":"","lua_type":"GenericTable"}],"returns":[{"desc":"","lua_type":"number"}],"function_type":"static","source":{"line":37,"path":"src/Util/Table.lua"}},{"name":"Keys","desc":"Returns an array of keys from a table.","params":[{"name":"Table","desc":"","lua_type":"GenericTable"}],"returns":[{"desc":"","lua_type":"Array<any>"}],"function_type":"static","source":{"line":57,"path":"src/Util/Table.lua"}},{"name":"Values","desc":"Returns an array of values from a table.","params":[{"name":"Table","desc":"","lua_type":"GenericTable"}],"returns":[{"desc":"","lua_type":"Array<any>"}],"function_type":"static","source":{"line":77,"path":"src/Util/Table.lua"}},{"name":"Copy<T>","desc":"Copies a table and returns a new table with the same values. Has the option to DeepCopy the table.","params":[{"name":"TableToCopy","desc":"","lua_type":"T"},{"name":"IsDeep","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"T"}],"function_type":"static","source":{"line":98,"path":"src/Util/Table.lua"}},{"name":"Merge<A, B>","desc":"Merges two tables together and returns the result of the merge.","params":[{"name":"To","desc":"","lua_type":"A"},{"name":"From","desc":"","lua_type":"B"},{"name":"IsDeep","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"A & B"}],"function_type":"static","source":{"line":124,"path":"src/Util/Table.lua"}},{"name":"Reconcile<A, B>","desc":"Reconciles two tables together and returns the result of the reconciliation.","params":[{"name":"To","desc":"","lua_type":"A"},{"name":"From","desc":"","lua_type":"B"},{"name":"IsDeep","desc":"","lua_type":"boolean?"}],"returns":[{"desc":"","lua_type":"A & B"}],"function_type":"static","source":{"line":156,"path":"src/Util/Table.lua"}},{"name":"DeepFreeze","desc":"Recursively freezes all tables within a table.","params":[{"name":"TableToFreeze","desc":"","lua_type":"GenericTable"}],"returns":[],"function_type":"static","source":{"line":182,"path":"src/Util/Table.lua"}},{"name":"IsArray","desc":"Determines if a table is an array or not.","params":[{"name":"TableToCheck","desc":"","lua_type":"GenericTable"}],"returns":[{"desc":"","lua_type":"boolean"}],"function_type":"static","source":{"line":204,"path":"src/Util/Table.lua"}},{"name":"Reverse","desc":"Reverses the order of elements in an array.","params":[{"name":"TableToReverse","desc":"","lua_type":"Array<any>"}],"returns":[],"function_type":"static","source":{"line":219,"path":"src/Util/Table.lua"}}],"properties":[],"types":[],"name":"Table","desc":"Utility functions specifically for tables.","private":true,"source":{"line":25,"path":"src/Util/Table.lua"}}')}}]);