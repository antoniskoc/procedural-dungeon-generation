function scr_bits_count(_bits){
	var c =0;
	while (_bits != 0){_bits &= (_bits -1); c++;}
	return c;
}