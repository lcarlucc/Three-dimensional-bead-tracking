% first image is correct orientation

function  [out] = intAlignIm( imA, imB, precision )
fftA = fft2(imA);

fftB = fft2(imB);


try

    out = dftregistration(fftA,fftB,precision);

catch

    'hi'

end

end