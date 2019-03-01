function Pendulum(canvas){
	this.plength = 70;
	this.pradius = 10;
	this.pwidth = 100;
	this.theta = 0;
	this.canvas = canvas;
	this.ctx = canvas.getContext('2d');
}

Pendulum.prototype.set_theta = function(t){
	console.log(t)
	this.theta = t + Math.PI;
}

Pendulum.prototype.draw = function(){
	var {plength, pradius, pwidth, theta, canvas, ctx} = this;
	var {sin, cos} = Math;

	var end = (l, t) => (new Point(l*sin(t), l*cos(t)));

	var origin = new Point(canvas.width/2, canvas.height/2);
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	origin.translate(ctx, function(){
		var pend = end(plength, theta);
		var stick = new Line(new Point(0, 0), pend, "#000");
		var ball = new Circle(pend, pradius, "#fff");
		stick.draw(ctx);
		ball.draw(ctx);
	});
}


function __init__(container, theta){
	var canvas = document.createElement('canvas');
	canvas.width = "300";
	canvas.height = "200";
	container.appendChild(canvas);
	container.className += " container"

	var p = new Pendulum(canvas);
	p.set_theta(theta);
	// p.draw(0);
	return p;
}


// __init__(document.body)
