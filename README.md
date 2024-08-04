## Quantized Inference processor For Custom CNN model 
### (Conv layer : 2 , MLP layer : 2)


### Weight Quantization => Binary Multiply Method (0.22 -> 0.22 * 32 = ~7)
![image](https://github.com/user-attachments/assets/b78332e1-0224-418d-9994-154a2dfa60b4)


### Functional Simulation
![image](https://github.com/user-attachments/assets/1891ce76-fe1a-4398-9784-b77bcf0cc4f2)
(For one image (28x28x1), it takes** ~2400 cycles** for inferece)\n
(It takes about 790 Cycles for setting weight from Block ROM)\n
(It stores intermediate results in Block RAM)
