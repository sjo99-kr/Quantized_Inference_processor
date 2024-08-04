## Quantized Inference processor For Custom CNN model 
### (Conv layer : 2 , MLP layer : 2) 


### Weight Quantization => Binary Multiply Method 
ex) weight : 0.22 , Quantized Weight : 0.22 * 256 = 56)



### HARDWARE Block Diagram
![image](https://github.com/user-attachments/assets/b78332e1-0224-418d-9994-154a2dfa60b4)


### Functional Simulation
![image](https://github.com/user-attachments/assets/1891ce76-fe1a-4398-9784-b77bcf0cc4f2)

(For one image (28x28x1), it takes ~2400 cycles for inferece)

(It takes about 790 Cycles for setting weight from Block ROM)

(It stores intermediate results in Block RAM)
