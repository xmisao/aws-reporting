function NaN2null(val){
  if(isNaN(val)){
    return null;
  } else {
    return val;
  }
}

function drawGraph(json_path){
  var margin = {top: 40, right: 20, bottom: 60, left: 50},
      width = 600 - margin.left - margin.right,
      height = 290 - margin.top - margin.bottom;

  var parseDate = d3.time.format.iso.parse

  var x = d3.time.scale()
      .range([0, width]);

  var y = d3.scale.linear()
      .range([height, 0]);

  var xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
      .innerTickSize(-height)
      .outerTickSize(0)
      .tickPadding(10);

  var yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")
      .innerTickSize(-width)
      .outerTickSize(0)
      .tickPadding(10)
      .tickFormat(d3.format('s'));

  var max_line = d3.svg.line()
      .x(function(d) { return x(d.timestamp); })
      .y(function(d) { return y(d.maximum); });

  var min_line = d3.svg.line()
      .x(function(d) { return x(d.timestamp); })
      .y(function(d) { return y(d.minimum); });

  var avg_line = d3.svg.line()
      .x(function(d) { return x(d.timestamp); })
      .y(function(d) { return y(d.average); });

  var sum_line = d3.svg.line()
      .x(function(d) { return x(d.timestamp); })
      .y(function(d) { return y(d.sum); });

  var count_line = d3.svg.line()
      .x(function(d) { return x(d.timestamp); })
      .y(function(d) { return y(d.count); });

  var svg_element = d3.select("#graph").append("svg")
                      .attr("width", width + margin.left + margin.right)
                      .attr("height", height + margin.top + margin.bottom)

  var svg = svg_element.append("g")
                       .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

  d3.json(json_path, function(error, info_data) {
    info = info_data.info;
    data = info_data.datapoints;
    data.forEach(function(d) {
      d.timestamp = parseDate(d.timestamp);
      d.maximum = +d.maximum;
      d.minimum = +d.minimum;
      d.average = +d.average;
      d.sum = +d.sum;
      d.count = +d.sample_count;
    });

    x.domain([parseDate(info.start_time), parseDate(info.end_time)]);
    y.domain([0,
              Math.max(0.001, d3.extent(data, function(d) { return Math.max(NaN2null(d.minimum), NaN2null(d.average), NaN2null(d.maximum), NaN2null(d.sum), NaN2null(d.count)); })[1])]);

    svg.append("text")
       .text(info.metric_name)
       .attr("transform", "translate(" + -40 + "," + - margin.top / 2 + ")")
       .attr("text-anchor", "left")
       .style("font-size", "14px")
       .style("font-weight", "bold")
       .append("tspan")
       .text('(' + info.unit + ')')
       .style("font-size", "10px")
       .attr("dx", "5");

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)

    var lines = 0;
    if(info.statistics.indexOf("Maximum") >= 0){
      lines++;
      svg.append("path")
          .datum(data)
          .attr("class", "max_line")
          .attr("d", max_line)
          .attr("data-legend", 'Max');
    }
    if(info.statistics.indexOf("Minimum") >= 0){
      lines++;
      svg.append("path")
          .datum(data)
          .attr("class", "min_line")
          .attr("d", min_line)
          .attr("data-legend", 'Min');
    }
    if(info.statistics.indexOf("Average") >= 0){
      lines++;
      svg.append("path")
          .datum(data)
          .attr("class", "avg_line")
          .attr("d", avg_line)
          .attr("data-legend", 'Avg');
    }
    if(info.statistics.indexOf("Sum") >= 0){
      lines++;
      svg.append("path")
          .datum(data)
          .attr("class", "sum_line")
          .attr("d", sum_line)
          .attr("data-legend", 'Sum');
    }
    if(info.statistics.indexOf("TotalCount") >= 0){
      lines++;
      svg.append("path")
          .datum(data)
          .attr("class", "count_line")
          .attr("d", count_line)
          .attr("data-legend", 'Count');
    }

    legend = svg.append("g")
                .attr("class","legend")
                .style("font-size","12px")
                .call(d3.legend);

    //legend_bb = legend.getBBox();
    //console.log(legend_bb);
    legend.attr("transform","translate(" + (270 - lines * 30) + "," + 230 + ")")

    if(info.status == 'OK'){
      svg_element.attr('class', 'status-ok');
    } else if(info.status == 'ALARM') {
      svg_element.attr('class', 'status-alarm');
    } else {
      svg_element.attr('class', 'status-none');
    }
  });
}
