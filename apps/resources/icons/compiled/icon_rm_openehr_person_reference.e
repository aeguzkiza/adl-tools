note
	description: "Icon loader class generated by icon_code_gen"
	keywords:    "Embedded icons"
	author:      "Thomas Beale <thomas.beale@oceaninformatics.com>"
	support:     "http://www.openehr.org/issues/browse/AWB"
	copyright:   "Copyright (c) 2013- Ocean Informatics Pty Ltd"
	license:     "Apache 2.0 License <http://www.apache.org/licenses/LICENSE-2.0.html>"

class ICON_RM_OPENEHR_PERSON_REFERENCE

inherit
	ICON_SOURCE

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization
		do
			key := "rm/openehr/person_reference"
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
					A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) 
					A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) 
					A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) 
					A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,DB,DB,DB) A(FF,6D,6D,6D) A(FF,6B,6B,6B) 
					A(FF,49,49,49) A(FF,1F,1F,1F) A(FF,5D,5D,5D) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,63,63,63) A(FF,5D,5D,5D) A(FF,51,51,51) A(FF,2C,2C,2C) A(FF,1C,1C,1C) A(FF,43,43,43) A(FF,FF,FF,FF) 
					A(00,00,00,00) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,54,54,54) 
					A(FF,78,78,78) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,C0,C0,C0) A(FF,78,78,78) A(FF,8D,8D,8D) A(00,00,00,00) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) 
					A(FF,00,00,80) A(FF,01,34,8D) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,68,68,68) A(FF,80,80,80) A(FF,DF,DF,DF) A(FF,CB,CB,CB) A(FF,9C,9C,9C) 
					A(FF,78,78,78) A(FF,89,89,89) A(00,00,00,00) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(00,00,00,00) A(00,00,00,00) 
					A(00,00,00,00) A(FF,A3,A3,A3) A(FF,87,87,87) A(FF,9D,9D,9D) A(FF,93,93,93) A(FF,79,79,79) A(FF,7B,7B,7B) A(FF,FF,FF,FF) A(00,00,00,00) A(00,00,00,00) 
					A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,AE,AE,AE) A(FF,5C,5C,5C) 
					A(FF,74,74,74) A(FF,74,74,74) A(FF,B4,B4,B4) A(FF,AC,AC,AC) A(00,00,00,00) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) 
					A(00,00,00,00) A(00,00,00,00) A(00,00,00,00) A(FF,D4,D4,D4) A(FF,F4,F4,F4) A(FF,FF,FF,FF) A(FF,F0,F0,F0) A(FF,B2,B2,B2) A(FF,EF,EF,EF) A(FF,68,68,68) 
					A(FF,BF,BF,BF) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(00,00,00,00) A(00,00,00,00) A(FF,CB,CB,CB) A(FF,DD,DD,DD) 
					A(FF,EA,EA,EA) A(FF,E2,E2,E2) A(FF,FF,FF,FF) A(FF,C0,C0,C0) A(FF,FA,FA,FA) A(FF,72,72,72) A(FF,7D,7D,7D) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) 
					A(FF,00,00,80) A(FF,01,34,8D) A(00,00,00,00) A(00,00,00,00) A(FF,D4,D4,D4) A(FF,DC,DC,DC) A(FF,D2,D2,D2) A(FF,CB,CB,CB) A(FF,CA,CA,CA) A(FF,D9,D9,D9) 
					A(FF,A8,A8,A8) A(FF,70,70,70) A(FF,77,77,77) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(FF,FF,FF,FF) A(FF,FF,FF,FF) 
					A(FF,B5,B5,B5) A(FF,CB,CB,CB) A(FF,C4,C4,C4) A(FF,B2,B2,B2) A(FF,B4,B4,B4) A(FF,8E,8E,8E) A(FF,5C,5C,5C) A(FF,70,70,70) A(FF,5E,5E,5E) A(00,00,00,00) 
					A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(FF,FF,FF,FF) A(FF,FF,FF,FF) A(FF,99,99,99) A(FF,AE,AE,AE) A(FF,AF,AF,AF) A(FF,A3,A3,A3) 
					A(FF,85,85,85) A(FF,8D,8D,8D) A(FF,61,61,61) A(FF,60,60,60) A(FF,7C,7C,7C) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) 
					A(00,00,00,00) A(FF,FF,FF,FF) A(FF,9A,9A,9A) A(FF,90,90,90) A(FF,90,90,90) A(FF,8B,8B,8B) A(FF,7E,7E,7E) A(FF,64,64,64) A(FF,62,62,62) A(FF,7D,7D,7D) 
					A(FF,F7,F7,F7) A(00,00,00,00) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,01,34,8D) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) 
					A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) A(FF,00,00,80) 
					A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) 
					A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) A(FF,01,34,8D) ;
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