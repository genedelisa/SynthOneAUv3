platform :ios, '9.0'
use_frameworks!

# This enables the cutting-edge staging builds of AudioKit, comment this line to stick to stable releases
#source 'https://github.com/AudioKit/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'

def available_pods
    pod 'AudioKit'
    pod 'Audiobus'
    pod 'Disk', '~> 0.3.2'

    pod 'ChimpKit'
    pod 'OneSignal', '>= 2.6.2', '< 3.0'
end

target 'AudioKitSynthOne' do
    available_pods 
end

target 'SynthOneDSP' do
    #    inherit! :search_paths
    
            pod 'AudioKit'
    #        pod 'Audiobus'
    #        pod 'Disk', '~> 0.3.2'
        # pod 'OneSignal', '>= 2.6.2', '< 3.0'

end


target 'OneSignalNotificationServiceExtension' do
  pod 'OneSignal', '>= 2.6.2', '< 3.0'
  #pod 'AudioKit'
end


# https://stackoverflow.com/questions/46932341/class-is-implemented-in-both-one-of-the-two-will-be-used-which-one-is-undefine?rq=1

=begin

post_install do |installer|
    sharedLibrary = installer.aggregate_targets.find { |aggregate_target| aggregate_target.name == 'Pods-AudioKit' }
    installer.aggregate_targets.each do |aggregate_target|
        if aggregate_target.name == 'Pods-AudioKitSynthOne'
            aggregate_target.xcconfigs.each do |config_name, config_file|
                sharedLibraryPodTargets = sharedLibrary.pod_targets
                aggregate_target.pod_targets.select { |pod_target| sharedLibraryPodTargets.include?(pod_target) }.each do |pod_target|
                    pod_target.specs.each do |spec|
                        frameworkPaths = unless spec.attributes_hash['ios'].nil? then spec.attributes_hash['ios']['vendored_frameworks'] else spec.attributes_hash['vendored_frameworks'] end || Set.new
                    frameworkNames = Array(frameworkPaths).map(&:to_s).map do |filename|
                        extension = File.extname filename
                        File.basename filename, extension
                    end
                    frameworkNames.each do |name|
                        if name != '[DUPLICATED_FRAMEWORK_1]' && name != '[DUPLICATED_FRAMEWORK_2]'
                            raise("Script is trying to remove unwanted flags: #{name}. Check it out!")
                        end
                        puts "Removing #{name} from OTHER_LDFLAGS"
                        config_file.frameworks.delete(name)
                    end
                end
            end
            xcconfig_path = aggregate_target.xcconfig_path(config_name)
            config_file.save_as(xcconfig_path)
        end
    end
end
end


=end
