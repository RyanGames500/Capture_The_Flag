image_alpha += Desc


image_blend = make_color_rgb(ColorFinal.red,ColorFinal.green,ColorFinal.blue)
			
if image_alpha <= 0
	instance_destroy()