if (typeof data !== 'undefined') {
    var w = 240,
    h = 240,
    r = h/2;

var color = d3.scale.ordinal()
    .range(["#039317", "#921377", "#E6E6E6", "#214BB5"]);

var vis = d3.select('#chart')
    .append("svg:svg")
    .data([data])
    .attr("width", w)
    .attr("height", h)
    .append("svg:g")
    .attr("transform", "translate(" + r + "," + r + ")");

var pie = d3.layout.pie().value(function(d){return d.value;});

// declare an arc generator function
var arc = d3.svg.arc().outerRadius(r - 10).innerRadius(r - 70);

// select paths, use arc generator to draw
var arcs = vis.selectAll("g.slice").data(pie).enter().append("svg:g").attr("class", "slice");
arcs.append("svg:path")
    .attr("fill", function(d, i){
        return color(i);
    })
    .attr("d", function (d) {
        return arc(d);
    });

// add the text
/*
arcs.append("svg:text").attr("transform", function(d) {
    d.innerRadius = r;
    d.outerRadius = r;
    return "translate(" + arc.centroid(d) + ")";}).attr("text-anchor", "middle").attr("fill", "white")
    .style("text-transform", "uppercase")
    .text(function(d, i) {
  	if (data[i].value > 0) {
    	    return data[i].label;
  	}
    });
    */
}
