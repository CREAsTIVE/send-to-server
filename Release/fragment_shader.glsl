#version 430 core

out vec4 color;

uniform float Time1s;
uniform float Time;
uniform float TimeSin;
uniform float TimeCos;
uniform vec2 sizeOut;
uniform float MaxCells;
uniform float Dp;
uniform float XYm;
uniform int MCOMC;
uniform int NLiveCells;
uniform float tmNCs;
uniform sampler2D CellSX;
uniform sampler2D CellSY;
uniform sampler2D CellSR;
uniform sampler2D CellSC;
uniform sampler2D NMAP;
uniform sampler2D MAP;
uniform sampler2D texture;
uniform  float mst;

float length(vec2 Dot1, vec2 Dot2){
return(sqrt((Dot1.x-Dot2.x)*(Dot1.x - Dot2.x)+(Dot1.y-Dot2.y)*(Dot1.y-Dot2.y)));}

float nom(float n){
return(n * (MaxCells)/(MaxCells-1.f) / MaxCells);}

vec3 CellSCF(float n){
n = nom(n);
vec4 v = texture2D(CellSC, vec2(n , 1.f));
return(vec3(v.r,v.g,v.b));}

float CellSRF(float n){
n = nom(n);
vec4 v = texture2D(CellSR, vec2(n , 0.f));
return(((v.r * 1.f + v.g * 256.f + v.b * 65536.f + v.a * 16777216.f) / 16777216.f)*2.f);}

float CellSXF(float n){
n = nom(n);
vec4 v = texture2D(CellSX, vec2(n , 0.f));
return(((v.r * 1.f + v.g * 256.f + v.b * 65536.f + v.a * 16777216.f) / 16777216.f)*2.f);}

float CellSYF(float n){
n = nom(n);
vec4 v = texture2D(CellSY, vec2(n , 0.f));
return(((v.r * 1.f + v.g * 256.f + v.b * 65536.f + v.a * 16777216.f) / 16777216.f)*2.f);}



void main(){
vec2 Pos = gl_FragCoord.xy/sizeOut.xy;
vec2 Posf= gl_FragCoord.xy/sizeOut.xy;
Posf.y = 1.f - Posf.y;
Posf = Posf/mst+0.5f-0.5f/mst;
vec4 Xc =    texture2D(CellSX, Pos.xy);
vec4 alpha = texture2D(texture, Pos.xy);
vec3 pixel; //хранит конечную цветовую информацию

//рисуем фон и освещение
float lengthCentor = sqrt((Posf.x-0.5f)*(Posf.x-0.5f)+(Posf.y-0.5f)*(Posf.y-0.5f));
//float ling = 1.f - lengthCentor;
//float ling = 1.f - Posf.y;
float ling = (lengthCentor * 2.f) * (1.f - Posf.y);
ling = ling * ling * ling;
pixel.r = min(255.f, 0.745f + ling / 2.f);
pixel.g = 0.745f + ling / 5.f;
pixel.b = 1.f - ling * ling * 0.3f;

if(lengthCentor>0.505f){
pixel.r = 180.f/255.f;
pixel.g = 185.f/255.f;
pixel.b = 250.f/255.f;
}else 
if(lengthCentor>0.5f){
pixel.r = pixel.r /2.f;
pixel.g = pixel.g /2.f;
pixel.b = pixel.b /2.f;
}

float Ac = 1.f / XYm;
float Acleg = (XYm + 1.f) / XYm + 1.f;

//pixel.r -= texture2D(NMAP, vec2(Posf.x, Posf.y)).r * 40.f;
//pixel.g -= texture2D(NMAP, vec2(Posf.x, Posf.y)).r * 40.f;
//pixel.b -= texture2D(NMAP, vec2(Posf.x, Posf.y)).r * 40.f;

vec3 pixelm[4];
for(int l=0; l<4; l++){
pixelm[l] = pixel.rgb;}


//рисуем клетки
vec2 Posf0 = Posf;
for(int l=0; l<4; l++){

Posf.x = Posf0.x + (l % 2)  / (sizeOut.x * 2.f * mst);
Posf.y = Posf0.y + (l / 2)  / (sizeOut.y * 2.f * mst);
float Xm = Posf.x;
float Ym = Posf.y;


float shL=10.f;
float shL2=10.f;
float c1=-1.f;
float c2=-1.f;
//нахождение номеров 2-х ближайших
if(false){

for(float n1=0; n1<NLiveCells; n1++){
float n = n1*1.001f;
vec2 Cpos = vec2(CellSXF(n),CellSYF(n));
float l = length(Posf, Cpos);
if ( l < CellSRF(n) ) 
if ( l/CellSRF(n) < shL){
c2=c1;
shL2 = shL;
shL=l/CellSRF(n);
c1=n;} 
else if (l / CellSRF(n) < shL2){
shL2=l/CellSRF(n);
c2=n;
}}
}else{

vec2 bPosf;
for(float xs=-0.999f;xs<2.f;xs++){
for(float ys=-0.999f;ys<2.f;ys++){
bPosf=vec2(Posf.x+xs*Ac, Posf.y+ys*Ac);

float nmap = texture2D(NMAP, vec2(bPosf.x, bPosf.y)).r * 256.f - 0.1f;
for(float n1=0.f; n1 < nmap; n1++){

float n = 
floor(texture2D(MAP, vec2(bPosf.x, (bPosf.y + n1) / MCOMC)).r * 255.f) +
floor(texture2D(MAP, vec2(bPosf.x, (bPosf.y + n1) / MCOMC)).g * 256.f) * 256;

vec2 Cpos = vec2(CellSXF(n),CellSYF(n));
float l = length(Posf, Cpos);
if ( l < CellSRF(n) ) 
if ( l/CellSRF(n) < shL){
c2=c1;
shL2 = shL;
shL=l/CellSRF(n);
c1=n;} 
else if (l / CellSRF(n) < shL2){
shL2=l/CellSRF(n);
c2=n;
}}
}}

}

//функция отрисовки
if(c1>-1.f){
vec2 Cpos = vec2(CellSXF(c1),CellSYF(c1));

float nr;
if(c2>-1.f){
nr = length(Posf,Cpos)/CellSRF(c1);
if(nr>0.2)
nr += (CellSRF(c2)-length(Posf,vec2(CellSXF(c2),CellSYF(c2))))/CellSRF(c2);}
else{nr = length(Posf,Cpos)/CellSRF(c1);}


if(!((nr < 0.2) || ((nr > 0.7) && (nr < 0.8)) || (nr > 0.9))){
pixelm[l].r = (pixel.r + CellSCF(c1).r*2.f) / 3.f;
pixelm[l].g = (pixel.g + CellSCF(c1).g*2.f) / 3.f;
pixelm[l].b = (pixel.b + CellSCF(c1).b*2.f) / 3.f;
//pixelm[l].r = pixel.r / NLiveCells + c1 / NLiveCells;
//pixelm[l].g = pixel.r / NLiveCells + c1 / NLiveCells;
//pixelm[l].b = pixel.r / NLiveCells + c1 / NLiveCells;
}
else{
pixelm[l].r = CellSCF(c1).r / 2.f;
pixelm[l].g = CellSCF(c1).g / 2.f;
pixelm[l].b = CellSCF(c1).b / 2.f;
}}}


color.r = (pixelm[0].r+pixelm[1].r+pixelm[2].r+pixelm[3].r)/4.f;
color.g = (pixelm[0].g+pixelm[1].g+pixelm[2].g+pixelm[3].g)/4.f;
color.b = (pixelm[0].b+pixelm[1].b+pixelm[2].b+pixelm[3].b)/4.f;
color.a = alpha.a;
}