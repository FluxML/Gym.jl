// Basic utilities for point, line, circle

var __ = e => document.querySelector(e);

var c = 180/Math.PI;
var deg = (e) => e*c;
var rad = (e) => e/c;

(function(obj){

	Object.assign(obj, {Point, Line, Rect, Circle});

	function Point(x, y, color="#000"){
		this.x = x;
		this.y = y;
		this.color = color;
	}

	Point.prototype.displace = function(other){
		this.x += other.x;
		this.y += other.y;
		return this;
	}

	Point.prototype.clone = function(){return new Point(this.x, this.y)}

	Point.prototype.draw = function(ctx){
		ctx.fillStyle = this.color;
		ctx.beginPath();
		ctx.arc(this.x,this.y, 2, 0, Math.PI*2);
		ctx.fill();
	}

	Point.prototype.translate = function(ctx, f){
		ctx.translate(this.x, this.y);
		f();
		ctx.translate(-this.x, -this.y);
	}

	Point.prototype.dist = function(other){
		return Math.sqrt(Math.pow(other.x - this.x,2) + Math.pow(other.y - this.y,2))
	}

	function Line(a, b, color="#000"){
		this.a = a;
		this.b = b;
		this.color = color;
	}

	Line.prototype.draw = function(ctx, dashed=false){
		ctx.strokeStyle = this.color;
		ctx.beginPath();
		if(dashed){
			ctx.setLineDash([2, 1]);
		}
		ctx.moveTo(this.a.x, this.a.y);
		ctx.lineTo(this.b.x, this.b.y);
		ctx.stroke();
	}

	Line.prototype.toRect = function(color="#000", p=4) {
		var angle = Math.atan((this.b.y - this.a.y)/(this.b.x - this.a.x));
		var a = this.a;
		var b = this.b;
		if(a.x > b.x){
			a = this.b;
			b = this.a
		}
		var height = 2*p;
		var width = a.dist(b);
		return new Rect(a, angle, height, width, color);
	};

	function Rect(pivot, angle, height, width,color){
		this.pivot = pivot;
		this.angle = angle;
		this.height = height;
		this.width = width;
		this.color = color;
		this.borderColor = "#000";
		this.borderWidth = 1;
	}

	Rect.prototype.draw = function(ctx){
		ctx.translate(this.pivot.x, this.pivot.y);

		ctx.rotate(this.angle);

		ctx.fillStyle = this.color;
		ctx.fillRect(0, 0, this.width, this.height/2 - 1);
		ctx.fillRect(0, 0, this.width, -this.height/2 + 1);

		ctx.rotate(-this.angle);
		ctx.translate(-this.pivot.x, -this.pivot.y);
	}

	function Circle(center, radius, color="#000"){
		this.center = center;
		this.radius = radius;
		this.color = color;
	}

	Circle.prototype.draw = function(ctx, fill=true){
		ctx.beginPath();
		ctx.arc(this.center.x, this.center.y, this.radius, 0, 2*Math.PI);
		if(fill){
			ctx.fillStyle = this.color;
			ctx.fill();
		}else{
			ctx.strokeStyle = this.color;
			// ctx.strokeWidth =
			ctx.stroke();
		}
	}
})(window);
