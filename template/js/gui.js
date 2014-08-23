function get_query_string(){
  var result = {};
  var query = window.location.hash.substring(2);
  var parameters = query.split( '&' );
  for( var i = 0; i < parameters.length; i++ )
  {
    var element = parameters[ i ].split( '=' );
    var paramName = decodeURIComponent( element[ 0 ] );
    var paramValue = decodeURIComponent( element[ 1 ] );
    result[ paramName ] = paramValue;
  }
  return result;
}

function get_param(){
  var query = get_query_string(); 
  if(query.param){
    var param = JSON.parse(decodeURIComponent(query.param));
    return param;
  } else {
    return null;
  }
}

function state_decorate(state){
  if(state == 'OK'){
    return '<span class="state-ok">' + state + '</span>'
  } else if(state == 'ALARM'){
    return '<span class="state-alarm">' + state + '</span>'
  } else {
    return state;
  }
}

function show_report_info(){
  var header = "<h3>Report Information</h3>";
  var table = "<table>"; 
  table += '<tr><th>' + 'Start Time' + '</th><td>' + REPORT_INFO['start_time']  + '</td></tr>'
  table += '<tr><th>' + 'End Time' + '</th><td>' + REPORT_INFO['end_time']  + '</td></tr>'
  table += '<tr><th>' + 'Period' + '</th><td>' + REPORT_INFO['period']  + '</td></tr>'
  table += '<tr><th>' + 'Timestamp' + '</th><td>' + REPORT_INFO['timestamp']  + '</td></tr>'
  table += '<tr><th>' + 'Number of Metrics' + '</th><td>' + REPORT_INFO['num_of_metrics']  + '</td></tr>'
  table += '<tr><th>' + 'Version' + '</th><td>' + REPORT_INFO['version']  + '</td></tr>'
  table += "</table>"; 

  $("#report-info").html(header + table);
  table_striped();
  $("#report-info").css('display', 'block');
}

function show_alarms(){
  $("#graph").html("");

  var header = "<h3>Alarms</h3>";
  var table = "<table>";
  table += "<tr>";
  table += "<th>";
  table += "State";
  table += "</th>";
  table += "<th>";
  table += "Name";
  table += "</th>";
  table += "<th>";
  table += "Region > Namespace > Dimensions";
  table += "</th>";
  table += "<th>";
  table += "Metric Name";
  table += "</th>";
  table += "</tr>";
  for(var i = 0, n = ALARMS.length; i < n; i++){
    var alarm = ALARMS[i];
    table += "<tr>";
    table += "<td>";
    table += state_decorate(alarm.status);
    table += "</td>";
    table += "<td>";
    table += alarm.name;
    table += "</td>";
    table += "<td>";
    table += '<a href="' + get_link(alarm) + '">' + build_title(alarm) + '</a>';
    table += "</td>";
    table += "<td>";
    table += alarm.metric_name;
    table += "</td>";
    table += "</tr>";
  }
  table += "</table>";

  $("#alarms").html(header + table);

  table_striped();

  $("#alarms").css('display', 'block');
}

function hide_index_elements(){
  $("#alarms").css('display', 'none');
  $("#report-info").css('display', 'none');
}

function move(){
  var param = get_param();
  if(param){
    load(param);
  } else {
    $("#title").html("INDEX");
    show_report_info();
    show_alarms();
  }
}

function compare_dimensions(d0, d1){
  if(d0.length != d1.length){
    return false;
  }

  for(var i = 0, n = d0.length; i < n; i++){
    if(d0[i].name != d1[i].name){
      return false;
    }
    if(d0[i].value != d1[i].value){
      return false;
    }
  }

  return true;
}

function get_element(param){
  var region = param.region;
  var dimensions = param.dimensions; 

  for(var k = 0, l = METRICS.length; k < l; k++){
    namespace_table = METRICS[k];
    namespace = namespace_table.namespace;
    if(namespace != param.namespace){
      continue;
    }
    dimension_table = namespace_table.dimension_table;
    for(var i = 0, n = dimension_table.length; i < n; i++){
      for(var j = 0, m = dimension_table[i].elements.length; j < m; j++){
        var element = dimension_table[i].elements[j];
        
        if(region != element.region){
          continue;
        }
        if(compare_dimensions(dimensions, element.dimensions)){
          return element;
        }
      }
    }
  }

  return null;
}

function build_title(element){
  var title = "";
  title += element.region;
  title += " > ";
  title += element.namespace;
  title += " > ";
  title += serialize(element.dimensions);
  return title;
}

function load(param){
  hide_index_elements();

  var element = get_element(param);
  if(!element) return;

  $("#graph").html("");
  for(var i = 0, n = element.files.length; i < n; i++){
    drawGraph(element.files[i]);
  }

  var title = build_title(element);
  $("#title").html(title);
}

function serialize(dimensions){
  var result = [];
  if(dimensions.length == 0){
    return "(direct)";
  }
  for(var i = 0; i < dimensions.length; i++){
    result.push(dimensions[i].name + ' => ' + dimensions[i].value);
  }
  return result.join(', ');
}

function get_value_from_dimension(dimensions, name){
  for(var i = 0, n = dimensions.length; i < n; i++){
    if(dimensions[i].name == name){
      return dimensions[i].value
    }
  }
}

function table_striped(){
  $("tr:nth-child(odd)").addClass("odd");
  $("tr:nth-child(even)").addClass("even");
}

function get_link(element){
  var param = {region:element.region, namespace:element.namespace, dimensions:element.dimensions};
  return "#?param=" + encodeURIComponent(JSON.stringify(param));
}

function add_toggle(){
  $("h1").click(function(event){
      var body_id = event.target.id + '-body';
      $("#" + body_id).slideToggle();
  });
}

function has_name(dimension_table){
  for(var k = 0, l = dimension_table.elements.length; k < l; k++){
    element = dimension_table.elements[k];
    if(element.name){
      return true;
    }
  }
  return false;
}

function format_name(name){
  if(name){
    return name;
  } else {
    return "";
  }
}

function build_table(dimension_table){
  var has_name_flag = has_name(dimension_table);

  var table = "";

  table += "<table>";
  table += "<tr>";
  if(has_name_flag){
    table += "<th>Name</th>";
  }
  table += "<th>Region</th>";
  for(var j = 0, m = dimension_table.dimension_type.length; j < m; j++){
    table += "<th>" + dimension_table.dimension_type[j] + "</th>";
  }
  table += "</tr>";
  for(var k = 0, l = dimension_table.elements.length; k < l; k++){
    table += "<tr>";
    element = dimension_table.elements[k];
    if(has_name_flag){
      table += "<td>" + "<a href='" + get_link(element) + "'>" + format_name(element.name) + "</a>" + "</td>";
    }
    table += "<td>" + "<a href='" + get_link(element) + "'>" + element.region + "</a>" + "</td>";
    for(var j = 0, m = dimension_table.dimension_type.length; j < m; j++){
      table += "<td>" + "<a href='" + get_link(element) + "'>" + get_value_from_dimension(element.dimensions, dimension_table.dimension_type[j]) + "</a>" + "</td>";
    }
    table += "</tr>";
  }
  table += "</table>";

  return table;
}

function initialize(){
  d3.json('data/metrics.json', function(error, data) {
    ALARMS = data.alarms;
    METRICS = data.metrics;
    REPORT_INFO = data.report_info;
    for(var j = 0, m = METRICS.length; j < m; j++){
      var namespace_table = METRICS[j];
      var namespace = namespace_table.namespace;
      var id = namespace.replace('/', '-');
      var body_id = id + '-body';
      $('#metrics').append("<h1 id='" + id + "'>" + namespace + "</h1>" + "<div id='" + body_id + "'></div>");
      $('#' + body_id).toggle();
      for(var i = 0, n = namespace_table.dimension_table.length; i < n; i++){
        dimension_table = namespace_table.dimension_table[i];
        var table = build_table(dimension_table);
        $('#' + body_id).append(table);
      }
    }
    add_toggle();
    table_striped();
    move();
  });
}

METRICS = null;
ALARMS = null;
REPORT_INFO = null;
