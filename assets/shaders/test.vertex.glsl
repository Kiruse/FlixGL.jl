#version 330 core

layout(location = 0) in vec3 inPosition;
layout(location = 1) in vec4 inColor;
out vec4 vecColor;

uniform mat3 uniScreenTransform;

void main()
{
    gl_Position = vec4(uniScreenTransform * inPosition, 1);
    vecColor = inColor;
}