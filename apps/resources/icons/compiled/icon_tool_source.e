note
	description: "Icon loader class generated by icon_code_gen"
	keywords:    "Embedded icons"
	author:      "Thomas Beale <thomas.beale@oceaninformatics.com>"
	support:     "http://www.openehr.org/issues/browse/AWB"
	copyright:   "Copyright (c) 2013- Ocean Informatics Pty Ltd"
	license:     "Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>"

class ICON_TOOL_SOURCE

inherit
	ICON_SOURCE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization
		do
			key := "tool/source"
			make_with_size (16, 16)
			fill_memory
		end

feature {NONE} -- Image data
	
	c_colors_0 (a_ptr: POINTER; a_offset: INTEGER)
			-- Fill `a_ptr' with colors data from `a_offset'.
		external
			"C inline"
		alias
			"{
				{
					#define B(q) #q
					#ifdef EIF_WINDOWS
						#define A(a,r,g,b) B(\x##b\x##g\x##r\x##a)
					#else
						#define A(a,r,g,b) B(\x##r\x##g\x##b\x##a)
					#endif

					char l_data[] =
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(FF,26,61,B4) A(FF,27,64,BA) A(FF,28,67,C0) A(FF,28,6A,C5) A(FF,28,6A,C5) A(FF,29,6D,CA) A(FF,2A,70,D0) A(FF,3E,80,D6) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,27,64,BA) A(FF,FF,FF,FF) 
					A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,3E,80,D6) A(FF,52,8F,DC) A(FF,66,9E,E2) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,28,67,C0) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) 
					A(FF,52,8F,DC) A(FF,66,9E,E2) A(FF,7A,AE,E8) A(FF,8D,BE,ED) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(FF,28,6A,C5) A(FF,FF,FF,FF) A(FF,66,66,66) A(FF,6B,6B,6B) A(FF,70,70,70) A(FF,7A,7A,7A) A(FF,66,9E,E2) A(FF,7A,AE,E8) A(FF,8D,BE,ED) A(FF,A1,CD,F3) 
					A(FF,B5,DC,F9) A(00,00,00,00) A(FF,00,00,80) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,29,6D,CA) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) 
					A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,7A,AE,E8) A(FF,8D,BE,ED) A(FF,A1,CD,F3) A(FF,B5,DC,F9) A(FF,C9,EC,FF) A(00,00,00,00) A(FF,00,00,80) A(FF,00,00,80) 
					A(00,00,00,00) A(00,00,00,00) A(FF,2A,70,D0) A(FF,FF,FF,FF) A(FF,66,66,66) A(FF,6B,6B,6B) A(FF,70,70,70) A(FF,7A,7A,7A) A(FF,7F,7F,7F) A(FF,89,89,89) 
					A(FF,9E,9E,9E) A(FF,FF,FF,FF) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,FF) A(FF,00,00,FF) A(FF,00,00,80) A(00,00,00,00) A(FF,3E,80,D6) A(FF,FF,FF,FF) 
					A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,00,00,FF) A(FF,00,00,FF) 
					A(FF,00,00,FF) A(FF,00,00,FF) A(FF,00,00,FF) A(FF,00,00,80) A(FF,52,8F,DC) A(FF,FF,FF,FF) A(FF,70,70,70) A(FF,75,75,75) A(FF,7A,7A,7A) A(FF,89,89,89) 
					A(FF,94,94,94) A(FF,9E,9E,9E) A(FF,B3,B3,B3) A(FF,FF,FF,FF) A(FF,00,00,FF) A(FF,00,00,FF) A(FF,00,00,FF) A(FF,00,00,FF) A(FF,00,00,FF) A(00,00,00,00) 
					A(FF,66,9E,E2) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) 
					A(FF,70,94,B6) A(00,00,00,00) A(FF,00,00,FF) A(FF,00,00,FF) A(00,00,00,00) A(00,00,00,00) A(FF,7A,AE,E8) A(FF,FF,FF,FF) A(FF,7A,7A,7A) A(FF,7F,7F,7F) 
					A(FF,89,89,89) A(FF,9E,9E,9E) A(FF,A8,A8,A8) A(FF,B3,B3,B3) A(FF,C7,C7,C7) A(FF,FF,FF,FF) A(FF,5A,7F,A3) A(00,00,00,00) A(FF,00,00,FF) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(FF,8D,BE,ED) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,FF,FF,FF) 
					A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,44,69,91) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,A1,CD,F3) A(FF,B5,DC,F9) 
					A(FF,C9,EC,FF) A(FF,B3,D6,ED) A(FF,B3,D6,ED) A(FF,9C,C0,DA) A(FF,86,AA,C8) A(FF,70,94,B6) A(FF,5A,7F,A3) A(FF,44,69,91) A(FF,2D,53,7E) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) ;
					memcpy ((EIF_NATURAL_32 *)$a_ptr + $a_offset, &l_data, sizeof l_data - 1);
				}
			}"
		end

	build_colors (a_ptr: POINTER)
			-- Build `colors'
		do
			c_colors_0 (a_ptr, 0)
		end

end