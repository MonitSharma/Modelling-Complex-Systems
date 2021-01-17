import random, logging
import numpy as np
import matplotlib.pyplot as pl
from operator import itemgetter
from time import sleep
import pygame
def drawSquare(screen, currentColour, currentColumn, cellSize, currentRow):
    pygame.draw.rect(screen, currentColour, [currentColumn * cellSize, currentRow * cellSize,
                    (currentColumn + 1)* cellSize, (currentRow + 1) * cellSize])

''' Print the current generation '''
def printGenerationUniverse(universeList, currentTimeStep, cellCountX, cellCountY, normalCharacter,
                            susceptibleCharacter, infectedCharacter, recoveredCharacter):
    logging.info("TimeStep %3i:  " %currentTimeStep)
    rowLabel = "  "
    for l in range(cellCountX):
        rowLabel += str(l) +" "
    logging.info(rowLabel)
    for currentRow in range(cellCountY):
        logging.info ("%s %s" %(currentRow, universeList[currentRow].replace('0',normalCharacter+" ")
               .replace('1', susceptibleCharacter + " ")
               .replace('2', infectedCharacter + " ").replace('3', recoveredCharacter + " "))
              )
    return
''' This method calculates the new state of the cell based on Van Neumann neighborhood '''
def getNewState2D(currentRowNeighbours, upperRowNeighbours, lowerRowNeighbours,beta,gamma):
    newState = '1'

    leftCharacter = currentRowNeighbours[0]
    selfCharacter = currentRowNeighbours[1]
    rightCharacter = currentRowNeighbours[2]

    upperLeftCharacter = upperRowNeighbours[0]
    upperCenterCharacter = upperRowNeighbours[1]
    upperRightCharacter = upperRowNeighbours[2]

    lowerLeftCharacter = lowerRowNeighbours[0]
    lowerCenterCharacter = lowerRowNeighbours[1]
    lowerRightCharacter = lowerRowNeighbours[2]

    newState = selfCharacter

    if selfCharacter == '1': # If Normal and there is an Infected close, be Susceptible
        if leftCharacter == '2' or rightCharacter == '2' or\
        upperLeftCharacter == '2' or\
        upperRightCharacter == '2' or\
        upperCenterCharacter == '2'or\
        lowerLeftCharacter == '2' or\
        lowerRightCharacter == '2' or lowerCenterCharacter == '2':
            #betaChance =np.random.uniform(beta-(beta/2),beta+(beta/2))
            #betaChance=np.random.uniform()
            betaChance= (2 - np.random.uniform()) # UNIFORM
            if betaChance > 0 and betaChance < beta:
                newState = '2'
    elif selfCharacter == '2': # if Infected, calculate the probability to be Recovered 'to recover'
        gammaChance = (1 - np.random.normal(0.5, 1.0)) # NORMAL
        #gammaChance = (1 - np.random.uniform()) # UNIFORM
        #gammaChance=np.random.uniform()
        #betaChance = (2 - (np.random.poisson(2) % 10) * 0.1) # POISSON
        if gammaChance < gamma and gammaChance > 0:
            newState = '3'
    return newState




def screenplay(titile,cellCountX, cellCountY, info, total_iteration):
    #print(total_iteration)
    pygame.init()
    #colour code in RGB Combination
    BLACK = (0,0,0)
    WHITE = (255,255,255)
    BLUE =  (0,0,255)
    GREEN = (0,255,0)
    YELLOW =(255,255,0)
    RED = (255,0,0)
    ORANGE =(255,165,0)
    GRAY=(169,169,169)

    screenHeight = 600
    screenWidth = 600

    cellSize = screenHeight / cellCountX

    size = [int(screenHeight), int(screenWidth)]
    screen = pygame.display.set_mode(size)
    screen.fill(WHITE)
    pygame.display.set_caption("CA with SIR Model")

    #Loop until the user clicks the close button.
    clock = pygame.time.Clock()

    #while 1:
    # Make sure game doesn't run at more than 60 frames per second
    mainloop = True
    FPS = 30                           # desired max. framerate in frames per second.
    playtime = 0
    cycletime = 0
    interval = .45    #.15 how long one single images should be displayed in seconds
    picnr = 0

    #for Step in range(total_iteration):
    Step = 0
    while mainloop:
        milliseconds = clock.tick(FPS)
        seconds = milliseconds / 1000.0
        playtime += seconds
        cycletime += seconds
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                mainloop=False
        #print(cycletime,seconds,cycletime>seconds)
        if cycletime > interval:

            if Step >= total_iteration:
                pygame.quit()
                break
            else:
                Step += 1
            #pygame.time.delay(3000)
            pygame.display.set_caption("SIR with CA For infected spaced %s , CurrentTimeStep %3i:  " % (title,Step))
            cycletime = 0

            currentColour = BLACK
            for currentRow in range(cellCountY):# Draw a solid rectangle
                for currentColumn in range (cellCountX):
                    if Step > 0 and Step < total_iteration:
                        if info[Step][currentRow][currentColumn] == '1':
                            currentColour = WHITE
                        if info[Step][currentRow][currentColumn] == '2':
                            currentColour = ORANGE
                        if info[Step][currentRow][currentColumn] == '3':
                            currentColour = GRAY
                        drawSquare(screen, currentColour, currentColumn, cellSize, currentRow)

        pygame.display.flip()

    #pygame.quit()
    return Step

def centeredInitialization(cellCountX,cellCountY):
    List=['1'*cellCountX for i in range(cellCountY)]
    temp=''
    for i in range(cellCountX):
        if i==cellCountX//2:
            temp+='2'
        else:
            temp+='1'
    List[cellCountY//2]=temp
    return List

cellCountX = 50
cellCountY = 50


#beta = 0.00218*cellCountX*cellCountY # Chance to get S from neighbouring I
#gamma = 0.5 # Chance to get from I to R (or normal in our case)

# For this case no succeptible is remaining
beta=1.2247
gamma=0.1

#Normal case
#beta=1.2247
#gamma=0.5

#Few succeptible remaining
#beta=1.2247
#gamma=0.3


# Init values
susceptibleCharacter = 'S'
recoveredCharacter = 'R'
infectedCharacter ='I'
normalCharacter = '_'
extremeEndValue = '1'

universeList,RES = [],[]
info = [] #whole information store here
print()
print(' Succeptible is in WHITE Pixel '.center(80,'-'))
print(' Infected is in ORANGE Pixel '.center(80,'-'))
print(' Recovered in DARK-GRAY Pixel '.center(80,'-'))
print()
#uncomment for random initialization
S=int(input('Discription\n [1] Infected spaced Center\n [2] Infected spaced Randomly\n [Choose 1 or 2] : '))
if S==2:
    print('Printing Initial state'.center(80,'-'))
    # Randomise first state
    for currentColumn in range(cellCountY):
        universe = ''.join(random.choice('1111111111111111111111111111111111111111111111111111111111111111111112') for universeColumn in range(cellCountX))
        #print(universe)
        universeList.append(universe)
#sleep(1)
#'''
#For centered Infected case
#universeList=centeredInitialization(cellCountX,cellCountY)
else:
    universeList=centeredInitialization(cellCountX,cellCountY)

currentTimeStep=0
zeroCount = 0
oneCount = 0
twoCount = 0
threeCount = 0
for currentRow in range(cellCountY):
    zeroCount += universeList[currentRow].count('0')
    oneCount += universeList[currentRow].count('1')
    twoCount += universeList[currentRow].count('2')
    threeCount += universeList[currentRow].count('3')
RES.append([zeroCount, oneCount,twoCount, threeCount, currentTimeStep])
# Main Execution loop
while RES[-1][-3]!=0:
    #print('Table'.center(80,'-'))
    #printGenerationUniverse(universeList,currentTimeStep,cellCountX,cellCountY,normalCharacter,susceptibleCharacter,infectedCharacter,recoveredCharacter)
    #sleep(1)
    zeroCount = 0
    oneCount = 0
    twoCount = 0
    threeCount = 0
    for currentRow in range(cellCountY):
        zeroCount += universeList[currentRow].count('0')
        oneCount += universeList[currentRow].count('1')
        twoCount += universeList[currentRow].count('2')
        threeCount += universeList[currentRow].count('3')
    RES.append([zeroCount,oneCount, twoCount, threeCount, currentTimeStep])
    #print('Result'.center(80,'-'))
    #print(RES[-1])
    #sleep(1)
    oldUniverseList = []
    temp=[]
    #print('Old universe'.center(80,'*'))
    for currentRow in range(cellCountY):
        #print(extremeEndValue + universeList[currentRow] + extremeEndValue)
        oldUniverseList.append(extremeEndValue + universeList[currentRow] + extremeEndValue)
        temp+=[universeList[currentRow]]

    info+=[temp]
    #sleep(1)
    for currentRow in range(cellCountY):
        newUniverseRow = ''
        for currentColumn in range(cellCountX):
            upperRowNeighbours = '111'
            lowerRowNeighbours = '111'
            currentRowNeighbours = oldUniverseList[currentRow][currentColumn:currentColumn+3]
            if (currentRow - 1) >= 0:
                upperRowNeighbours = oldUniverseList[currentRow-1][currentColumn:currentColumn+3]
            if (currentRow + 1) < cellCountY:
                lowerRowNeighbours = oldUniverseList[currentRow+1][currentColumn:currentColumn+3]
            #print(currentRow,currentColumn,'---->',currentRowNeighbours,upperRowNeighbours,lowerRowNeighbours)
            newUniverseRow += getNewState2D(currentRowNeighbours, upperRowNeighbours, lowerRowNeighbours,beta,gamma)
            universeList[currentRow] = newUniverseRow
    currentTimeStep+=1

#total_iteration=currentTimeStep
#print(RES[-1])
#print(universeList)
timeStart = 0.0
timeEnd = currentTimeStep
timeStep = 1
timeRange = np.arange(timeStart, timeEnd + timeStart, timeStep)

#print(timeRange)
#print(list(map(itemgetter(0),RES)))
#print(list(map(itemgetter(1),RES)))
#print(list(map(itemgetter(2),RES)))
#print(list(map(itemgetter(3),RES)))
#print(list(map(itemgetter(4),RES)))
if S==1: title='Centered'
else: title='Randomly'

pl.plot(list(map(itemgetter(4), RES)), list(map(itemgetter(2), RES)), '-r', label='Infected')
pl.plot(list(map(itemgetter(4), RES)), list(map(itemgetter(1), RES)), '-b', label='Susceptibles')
pl.legend(loc=0)
pl.title('For infected spaced %s alpha %0.3lf and beta %0.4lf'%(title,gamma,beta))
pl.xlabel('Time')
pl.ylabel('Population')
pl.show()

pl.plot(list(map(itemgetter(4), RES)), list(map(itemgetter(3), RES)), '-r', label='Recovered')
pl.plot(list(map(itemgetter(4), RES)), list(map(itemgetter(1), RES)), '-b', label='Susceptibles')
pl.legend(loc=0)
pl.title('For infected spaced %s alpha %0.3lf and beta %0.4lf'%(title,gamma,beta))
pl.xlabel('Time')
pl.ylabel('Population')
pl.show()

pl.plot(list(map(itemgetter(4), RES)), list(map(itemgetter(3), RES)),'gray', label='Recovered')
pl.plot(list(map(itemgetter(4), RES)), list(map(itemgetter(1), RES)), 'green',label='Susceptibles')
pl.plot(list(map(itemgetter(4), RES)), list(map(itemgetter(2), RES)), 'black',label='Infected')
pl.legend(loc=0)
pl.title('For infected spaced %s alpha %0.3lf and beta %0.4lf'%(title,gamma,beta))
pl.xlabel('Time')
pl.ylabel('Population')
pl.show()

#print(len(info),info)
# Responsible for screenPlay
print(RES[0],'total_iteration',currentTimeStep)
print('Maximum Infected species ',max(list(map(itemgetter(2),RES))))
print('Time-Step for Maximum Infection spread : ',list(map(itemgetter(2),RES)).index(max(list(map(itemgetter(2),RES)))))

print(screenplay(title,cellCountX,cellCountY,info,currentTimeStep),currentTimeStep,RES[-1])