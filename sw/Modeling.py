import numpy as np 
import pandas as pd 
import matplotlib.pyplot as plt 
from sklearn.model_selection import train_test_split
from torchvision.datasets import MNIST

import torch
import torch.nn as nn
from torchvision import transforms, models

from torch.autograd import Variable
from torch import nn, optim
import torch.nn.functional as F

#------------------------------------------------------------------------------------------#
# Model setting Process #
#------------------------------------------------------------------------------------------#

class Quantized_Inference_Processor(nn.Module):
    def __init__(self):
        super(Quantized_Inference_Processor, self).__init__()
        self.conv_layer = nn.Sequential(
        # [batch_size, 1, 28, 28] -> [batch_size, 3, 24, 24]
            nn.Conv2d(in_channels = 1, out_channels =3, kernel_size = 5, bias=False),
            nn.ReLU(),
        # [batch_size ,3, 24, 24] -> [batch_size, 3, 12, 12]
            nn.MaxPool2d(kernel_size=2, stride=2),
            
        # [batch_size ,3, 12, 12] -> [batch_size, 3, 8, 8]   
            nn.Conv2d(in_channels = 3, out_channels = 3, kernel_size= 5, bias=False),
            nn.ReLU(),
        # [batch_size, 3, 8, 8] -> [batch_size, 3, 4, 4]
            nn.MaxPool2d(kernel_size=2, stride =2)
        )
        self.fc_layer = nn.Sequential(
            # [batch_size, 3, 4, 4] 
            # 4 x 4 x 3 (= 48) -> 16
            nn.Linear(48, 16),
            nn.ReLU(),
            nn.Linear(16, 10),
            nn.ReLU()
        )
        
    def forward(self, x):
        out = self.conv_layer(x) 
        out = out.view(-1) 
        out = self.fc_layer(out)
        out = self.softmax(out)
        return out

#------------------------------------------------------------------------------------------#
# Training Process #
#------------------------------------------------------------------------------------------#
model = Quantized_Inference_Processor()
device = torch.device("cpu")
model.to(device)


loss_func = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

epochs = 10
steps = 0
print_every = 50


for i in range(epochs):
    for j,[image,label] in enumerate(train_loader):
        x = image.to(device)
        y= label.to(device)
        
        optimizer.zero_grad()
        
        output = model.forward(x)
        
        loss = loss_func(output,y)
        loss.backward()
        optimizer.step()
        
        if j % 1000 == 0:
            print(loss)

        
