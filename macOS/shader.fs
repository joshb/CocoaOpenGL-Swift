/*
 * Copyright (C) 2010-2012 Josh A. Beam
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
#version 150

const int NUM_LIGHTS = 3;
const vec3 AMBIENT = vec3(0.1, 0.1, 0.1);
const float MAX_DIST = 2.5;
const float MAX_DIST_SQUARED = MAX_DIST * MAX_DIST;

uniform sampler2D normalmap;
uniform vec3 lightColor[NUM_LIGHTS];

in vec2 fragmentTexCoords;
in vec3 cameraVector;
in vec3 lightVector[NUM_LIGHTS];

out vec4 fragmentColor;

void
main()
{
	// initialize diffuse/specular lighting
	vec3 diffuse = vec3(0.0, 0.0, 0.0);
	vec3 specular = vec3(0.0, 0.0, 0.0);

	// get the fragment normal and camera direction
	vec3 fragmentNormal = (texture(normalmap, fragmentTexCoords).rgb * 2.0) - 1.0;
	vec3 normal = normalize(fragmentNormal);
	vec3 cameraDir = normalize(cameraVector);

	// loop through each light
	for(int i = 0; i < NUM_LIGHTS; ++i) {
		// calculate distance between 0.0 and 1.0
		float dist = min(dot(lightVector[i], lightVector[i]), MAX_DIST_SQUARED) / MAX_DIST_SQUARED;
		float distFactor = 1.0 - dist;

		// diffuse
		vec3 lightDir = normalize(lightVector[i]);
		float diffuseDot = dot(normal, lightDir);
		diffuse += lightColor[i] * clamp(diffuseDot, 0.0, 1.0) * distFactor;

		// specular
		vec3 halfAngle = normalize(cameraDir + lightDir);
		vec3 specularColor = min(lightColor[i] + 0.5, 1.0);
		float specularDot = dot(normal, halfAngle);
		specular += specularColor * pow(clamp(specularDot, 0.0, 1.0), 16.0) * distFactor;
	}

	vec4 sample = vec4(1.0, 1.0, 1.0, 1.0);
	fragmentColor = vec4(clamp(sample.rgb * (diffuse + AMBIENT) + specular, 0.0, 1.0), sample.a);
}