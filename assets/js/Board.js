(function(obj){

	Object.assign(obj, {Board});

	// render board
	function Board(container, config, {
		cartColor="#333",
		poleColor="#fff"
	}={}){
		console.log("init")
		// config : {
		// cart_height,
		// cart_length,
		// pole_length,
		// pole_diameter,
		// x_threshold
		// }
		Object.assign(this, config)

		const template = (
			'<canvas id="playground" width="1000" height="200"></canvas>'
		)
		container.innerHTML += template;

		this.container = container;
		this.cartColor = cartColor;
		this.poleColor = poleColor;

		this.canvas = container.querySelector('#playground');
		this.ctx = this.canvas.getContext('2d');
	}


	Board.prototype.render = function(
			state
		){
			console.log("render called");
			({x, theta} = state);

			({
				cart_height,
				cart_length,
				pole_length,
				pole_diameter,
				x_threshold
			} = this);

			var scaleToPixelsX = this.canvas.width*0.5/(cart_length/2 + x_threshold);
			var scaleToPixelsY = this.canvas.height*0.5/(cart_height + pole_length);

			this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);

			var cartX = (this.canvas.width/2 +  scaleToPixelsX*(x - cart_length/2));
			var cartY = this.canvas.height - scaleToPixelsY*cart_height;
			var rotateAngle = theta - Math.PI/2;

			// draw pole
			this.ctx.translate(cartX + scaleToPixelsX*cart_length/2, cartY + scaleToPixelsY*pole_diameter/2);
			this.ctx.fillStyle = this.poleColor;
			this.ctx.rotate(rotateAngle);
			this.ctx.scale(scaleToPixelsY, scaleToPixelsX); // needs to be (y, x) as this is rotated
			this.ctx.fillRect(-pole_diameter/2, -pole_diameter/2, pole_length, pole_diameter);
			this.ctx.scale(1/scaleToPixelsY, 1/scaleToPixelsX);
			this.ctx.rotate(-rotateAngle);
			this.ctx.translate(-(cartX + scaleToPixelsX*cart_length/2), -(cartY + scaleToPixelsY*pole_diameter/2));

			// draw cart
			this.ctx.fillStyle = this.cartColor;
			this.ctx.fillRect(cartX, cartY, scaleToPixelsX*cart_length, scaleToPixelsY*cart_height);

		}
})(window)
