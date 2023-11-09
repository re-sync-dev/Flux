"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[621],{36082:e=>{e.exports=JSON.parse('{"functions":[{"name":"async","desc":"Creates proxy promise to mimic specific methods of a promise.","params":[{"name":"Handler","desc":"","lua_type":"(Resolve: (T) -> (), Reject: (any) -> ()) -> ()"}],"returns":[{"desc":"","lua_type":"Promise<T>"}],"function_type":"static","source":{"line":41,"path":"src/PromiseProxy.lua"}}],"properties":[],"types":[{"name":"Promise<T>","desc":"Fixes the lack of any typing for evaera\'s Promise library.","lua_type":"{ Await: () -> T, Then: (Callback: (T) -> ()) -> (), Catch: (Callback: (string) -> ()) -> () }","source":{"line":24,"path":"src/PromiseProxy.lua"}}],"name":"PromiseProxy","desc":"Wrapper for evaera\'s Promise library to give the promise typing and removing camelCase.","source":{"line":30,"path":"src/PromiseProxy.lua"}}')}}]);