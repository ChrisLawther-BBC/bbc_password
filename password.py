#!/usr/bin/python3

import sys
import time

starttime = time.time()

passwords_file = 'leaked_passwords_v1.txt'
p = open(passwords_file, 'r')
passwords = p.read().splitlines()

toppassword_file = 'toppassword.txt'
t = open(toppassword_file, 'r')
toppasswords = t.read().splitlines()
for i in range(len(toppasswords)):
	toppasswords[i] = toppasswords[i].upper()

def char2num(l):
	return ord(l) - 65

def num2char(v):
	return chr(65 + v)

def decrypt(input):
	preValue = 3
	output = ''
	for letter in input:
		value = char2num(letter) - preValue
		if value < 0: value += 26
		preValue = char2num(letter)
		output = output + num2char(value) 
	return output

def encrypt (input):
	preValue = 3
	output = ''
	for letter in input:
		if not letter.isalpha(): continue
		newValue = (preValue + char2num(letter)) % 26
		preValue = newValue
		output = output + num2char(newValue)
	return output

count = 0
for pair in passwords:
	password = pair.split(',')[1]
	decrypted = decrypt(password)
	print (password, decrypted, end='')
	if decrypted in toppasswords:
		print (' -> found')
		count += 1
	else: print ('');
endtime = time.time()

print ('passwords found - ' + str(count))
print ('time taken - ' + str(endtime - starttime))
