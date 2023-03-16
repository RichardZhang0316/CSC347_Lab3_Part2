all: PiHist.cu
	nvcc -o PiHist PiHist.cu
clean:
	rm -f PiHist