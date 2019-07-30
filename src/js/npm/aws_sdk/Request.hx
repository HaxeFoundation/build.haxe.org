package js.npm.aws_sdk;

import haxe.Constraints;

@:jsRequire("aws-sdk", "Request")
extern class Request {
    public function on(event:String, callb:Function):js.Promise<Dynamic>;
    public function send(?callb:Function):js.Promise<Dynamic>;
    public function promise():js.Promise<Dynamic>;
    public function createReadStream():js.node.Stream<Dynamic>;
    public function eachItem(callb:Function):Void;
    public function eachPage(callb:Function):Void;
}