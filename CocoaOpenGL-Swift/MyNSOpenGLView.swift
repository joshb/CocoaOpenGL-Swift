/*
 * Copyright (C) 2015 Josh A. Beam
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

import Cocoa

class MyNSOpenGLView: NSOpenGLView
{
    var projectionMatrix = Matrix4()

    private var trackingArea: NSTrackingArea?

    override func awakeFromNib()
    {
        let attr = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile),
            NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), 24,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAlphaSize), 8,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 32,
            0
        ]

        let format = NSOpenGLPixelFormat(attributes: attr)
        let context = NSOpenGLContext(format: format!, shareContext: nil)

        self.openGLContext = context
        self.openGLContext?.makeCurrentContext()
    }

    override func reshape() {
        let frame = self.frame

        // Update the viewport.
        glViewport(0, 0, GLsizei(frame.size.width), GLsizei(frame.size.height))

        // Create projection matrix.
        let aspectRatio = Float(frame.size.width) / Float(frame.size.height)
        projectionMatrix = Matrix4.perspectiveMatrix(fov: M_PI_F / 4.0, aspect: aspectRatio, near: 0.1, far: 200.0)

        // Remove existing tracking area if necessary.
        if trackingArea != nil {
            removeTrackingArea(trackingArea!)
        }

        // Create new tracking area.
        let options: NSTrackingAreaOptions = [NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.ActiveWhenFirstResponder]
        trackingArea = NSTrackingArea(rect: frame, options: options, owner: self, userInfo: nil)
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(theEvent: NSEvent) {
        // Close the window when the escape key is pressed.
        if theEvent.keyCode == 0x35 {
            window?.close()
        }
    }

    func flush()
    {
        self.openGLContext?.flushBuffer()
    }
}
