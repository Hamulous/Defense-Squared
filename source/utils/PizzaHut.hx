package utils;

import haxe.Http;

class PizzaHut {
    public static function main() {
        var url = "https://your-pizza-api.com/order";
        var data = {
            "size": "large",
            "toppings": ["pepperoni", "mushrooms"]
        };
        
        var jsonData = haxe.Json.stringify(data);
        var http = new Http(url);
        
        http.onData = function(response) {
            trace("Order response: " + response);
        };
        
        http.onError = function(error) {
            trace("Order error: " + error);
        };
        
        http.request(true);
    }
}
