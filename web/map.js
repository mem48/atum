
// Setup Map
const map = new maplibregl.Map({
container: 'map', 
style: 'https://www.carbon.place/pmtiles/style_pbcc_mb.json',
center: [-3.2883, 55.9924], 
zoom: 7,
maxZoom: 18,
minZoom: 6,
attributionControl: false,
hash: true

});
 
// Add controls to the map.
map.addControl(new maplibregl.NavigationControl());
map.addControl(new maplibregl.AttributionControl({
customAttribution: 'Contains OS © Crown copyright 2022'
}));
map.addControl(new maplibregl.GeolocateControl({
positionOptions: {
enableHighAccuracy: true
},
trackUserLocation: true
})
,'top-right');
map.addControl(new maplibregl.ScaleControl({
  maxWidth: 80,
  unit: 'metric'
}),'bottom-right');


map.addControl(
new maplibregl.TerrainControl({
source: 'terrainSource',
exaggeration: 1.5
})
,'top-right');

    
map.on('load', function() {
map.addSource('rnet', {
	'type': 'vector',
	'tiles': [
	'https://www.wisemover.co.uk/tiles/rnet/{z}/{x}/{y}.pbf'
	],
	'minzoom': 6,
	'maxzoom': 13
});

map.addSource('terrainSource', {
  'type': 'raster-dem',
  'tiles': ["https://www.carbon.place/rastertiles/demwebp/{z}/{x}/{y}.webp"],
  'tileSize': 512,
  'minzoom': 0,
	'maxzoom': 9
});

map.addSource('hillshadeSource', {
  'type': 'raster-dem',
  'tiles': ["https://www.carbon.place/rastertiles/demwebp/{z}/{x}/{y}.webp"],
  'tileSize': 512,
  'minzoom': 0,
	'maxzoom': 9
});

map.addLayer(
{
'id': 'hillshading',
'source': 'hillshadeSource',
'type': 'hillshade'
},
'sea'
);

map.addLayer({
            'id': 'rnet',
            'type': 'line',
            'source': 'rnet',
            'source-layer': 'pct',
            'paint': {
              'line-color': ["step",["get","bicycle"],
              "rgba(0,0,0,0)",
              1,
              "#9C9C9C",10,
              "#FFFF73",50,
              "#AFFF00",100,
              "#00FFFF",250,
              "#30B0FF",500,
              "#2E5FFF",1000,
              "#0000FF",2000,
              "#FF00C5"],
              'line-width': 2
            }
        });

});

// Click on rnet
map.on('click', 'rent', function (e) {
var coordinates = e.lngLat;
var bicycle  = e.features[0].properties.bicycle ;
var all = e.features[0].properties.all;

var description = '<p> Bicycle: ' + bicycle  + '</p>' +
'<p> All: ' + all + '</p>';
 

new maplibregl.Popup()
.setLngLat(coordinates)
.setHTML(description)
.addTo(map);
});
 
// Change the cursor to a pointer when the mouse is over the places layer.
map.on('mouseenter', 'rnet', function () {
map.getCanvas().style.cursor = 'pointer';
});
 
// Change it back to a pointer when it leaves.
map.on('mouseleave', 'rnet', function () {
map.getCanvas().style.cursor = '';
});

