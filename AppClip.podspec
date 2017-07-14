Pod::Spec.new do |s|

  s.name        = "AppClip"
  s.version     = "0.1.0"
  s.summary     = "Create Web Clip for App."

  s.description = <<-DESC
                   Create Web Clip for App from App.
                   DESC

  s.homepage    = "https://github.com/nixzhu/AppClip"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "nixzhu" => "zhuhongxu@gmail.com" }
  s.social_media_url  = "https://twitter.com/nixzhu"

  s.ios.deployment_target   = "8.0"

  s.source          = { :git => "https://github.com/nixzhu/AppClip.git", :tag => s.version }
  s.source_files    = "AppClip/*.swift"
  s.requires_arc    = true

end
