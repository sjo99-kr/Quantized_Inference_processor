## Quantized Inference processor For Custom CNN model 
### (Conv layer : 2 , MLP layer : 2) 


### Weight Quantization => Binary Multiply Method 
ex) weight : 0.22 , Quantized Weight : 0.22 * 256 = 56)



### HARDWARE Block Diagram
![image](https://github.com/user-attachments/assets/b78332e1-0224-418d-9994-154a2dfa60b4)


### Functional Simulation
![image](https://github.com/user-attachments/assets/f5f25c5f-f7ca-4ac4-9bf5-b89a298f04c5)

(For one image (28x28x1), it takes ~2400 cycles for inferece)

(It takes about 790 Cycles for setting weights from Block ROM)
(you have to your own weights file(~.coe) for Block ROM setting)

(It stores intermediate results in Block RAM)
(Results of CONV1 and CONV2 data will go to BRAM.)

### Timing Spec
Clock : 145Mhz, WHS  0.146ns, WNS  1.718ns


### Hardware Resource 
LUT : ~ 11000, FF :  ~3000, BRAM: 3.5
