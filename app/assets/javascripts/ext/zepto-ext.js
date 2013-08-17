(function($) {
    // Add inner and outer width to zepto (adapted from https://gist.github.com/alanhogan/3935463)
    var ioDim = function(dimension, includeBorder) {
        return function (includeMargin) {
            var sides, size, elem;
            if (this) {
                elem = this;
                size = elem[dimension]();
                sides = {
                    width: ["left", "right"],
                    height: ["top", "bottom"]
                };
                sides[dimension].forEach(function(side) {
                    size += parseInt(elem.css("padding-" + side), 10);
                    if (includeBorder) {
                        size += parseInt(elem.css("border-" + side + "-width"), 10);
                    }
                    if (includeMargin) {
                        size += parseInt(elem.css("margin-" + side), 10);
                    }
                });
                return size;
            } else {
                return null;
            }
        }
    };
    ["width", "height"].forEach(function(dimension) {
        var Dimension = dimension.substr(0,1).toUpperCase() + dimension.substr(1);
        $.fn["inner" + Dimension] = ioDim(dimension, false);
        $.fn["outer" + Dimension] = ioDim(dimension, true);
    });

    var _is = $.fn.is, _filter = $.fn.filter;

    function visible(elem){
        elem = $(elem);
        return !!(elem.width() || elem.height()) && elem.css("display") !== "none";
    }

    $.fn.is = function(sel){
        if(sel === ":visible"){
            return visible(this);
        }
        if(sel === ":hidden"){
            return !visible(this);   
        }
        return _is.call(this, sel);
    }

    $.fn.filter = function(sel){
        if(sel === ":visible"){
            return $([].filter.call(this, visible));
        }
        if(sel === ":hidden"){
            return $([].filter.call(this, function(elem){
                return !visible(elem);
            }));
        }
        return _filter.call(this, sel);
    }
})(Zepto);