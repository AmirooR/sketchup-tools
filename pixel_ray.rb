require 'sketchup.rb'

def pixelRay( x, y, camera , width, height, f)
	x_disp = camera.aspect_ratio * ( (x - width/2) + 0.5)
	y_disp = (height/2 - y) + 0.5
	xx = Geom::Vector3d.new camera.xaxis.x * x_disp, camera.xaxis.y * x_disp, camera.xaxis.z * x_disp
	yy = Geom::Vector3d.new camera.yaxis.x * y_disp, camera.yaxis.y * y_disp, camera.yaxis.z * y_disp
	zz = Geom::Vector3d.new camera.direction.x * f,camera.direction.y * f,camera.direction.z * f
	aa = xx + yy + zz

	aa.normalize!
end

def writeDepth( file_name, width, height, compute_f)
	puts "Model"
	pi = 3.141592
	model = Sketchup.active_model
	puts "view"
	view = model.active_view
	puts "camera"
	camera = view.camera
	max_depth = 1000;
	default_normal = 0;
	puts "depths"
	depths = Array.new(height){ Array.new(width) }
	puts "File"
	ff = File.open(file_name,'w')
	nx = File.open('normalX.txt','w')
	ny = File.open('normalY.txt','w')
	nz = File.open('normalZ.txt','w')
	focal = camera.focal_length
	if compute_f
		puts("Computing F")
		focal = 0.5 * Math.sqrt( width * width + height*height) / Math.tan( pi * camera.fov/360.0)
	end
	(0..depths.size-1).each do |y|
		puts "#{y}"
		(0..depths[y].size-1).each do |x|
			pRay = pixelRay(x,y,camera,width, height, focal)
			ray = [camera.eye, pRay]
			b = model.raytest(ray)
			#b = item[0]
			if(b)
				v = b[0] - camera.eye
				depths[y][x] = v.length
				a = sprintf("%f",v.length)
				ff.write(a)
				ff.write(" ")
				aFace = b[1][(b[1].size)-1]
				if aFace.is_a?(Sketchup::Face)
					nx.write(aFace.normal.x)
					nx.write(" ")
					ny.write(aFace.normal.y)
					ny.write(" ")
					nz.write(aFace.normal.z)
					nz.write(" ")
				elsif aFace.is_a?(Sketchup::Edge)
					puts("Edge")
					aFaces = aFace.faces
					if aFaces.size > 0
						sumX = 0
						sumY = 0
						sumZ = 0
						(0..aFaces.size-1).each do |i|
							sumX += aFaces[i].normal.x
							sumY += aFaces[i].normal.y
							sumZ += aFaces[i].normal.z
						end
						puts(sumX)
						puts(aFaces.size)
						sumX = sumX/aFaces.size
						sumY = sumY/aFaces.size
						sumZ = sumZ/aFaces.size
						nx.write(sumX)
						nx.write(" ")
						ny.write(sumY)
						ny.write(" ")
						nz.write(sumZ)
						nz.write(" ")
					else
						puts("Warning edge has no face")
						nx.write(default_normal)
						nx.write(" ")
						ny.write(default_normal)
						ny.write(" ")
						nz.write(default_normal)
						nz.write(" ")	
					end
				else
					puts("Warning b is not nil but not face and not edge")
					puts(aFace.typename)
					nx.write(default_normal)
					nx.write(" ")
					ny.write(default_normal)
					ny.write(" ")
					nz.write(default_normal)
					nz.write(" ")	
				end

			else
				depths[y][x] = max_depth
				ff.write(max_depth)
				ff.write(" ")
				ff.write(a)
				ff.write(" ")
				nx.write(default_normal)
				nx.write(" ")
				ny.write(default_normal)
				ny.write(" ")
				nz.write(default_normal)
				nz.write(" ")
			end
		end
		ff.puts("\n")
		nx.puts("\n")
		ny.puts("\n")
		nz.puts("\n")
	end
	ff.close
	nx.close
	ny.close
	nz.close

end
