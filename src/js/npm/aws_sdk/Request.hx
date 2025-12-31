package js.npm.aws_sdk;

import haxe.Constraints;
import js.lib.Promise;

@:jsRequire("aws-sdk", "Request")
extern class Request {
    public function on(event:String, callb:Function):Promise<Dynamic>;
    public function send(?callb:Function):Promise<Dynamic>;
    public function promise():Promise<Dynamic>;
    public function createReadStream():js.node.Stream<Dynamic>;
    public function eachItem(callb:Function):Void;
    public function eachPage(callb:Function):Void;
}